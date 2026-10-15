<script setup lang="ts">
import type { OrgChartNode, OrgChartPoint } from 'd3-org-chart';

import type {
  OrganizationGraphDatum,
  OrganizationTreeNode,
} from './organization-tree';

import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';
import { i18n } from '@vben/locales';

import { OrgChart } from 'd3-org-chart';

import { $t } from '#/locales';

import {
  buildOrganizationGraphData,
  escapeOrganizationChartHtml,
} from './organization-tree';
import { getOrganizationTypeLabel } from './organization-types';

interface DataBoundLink extends SVGPathElement {
  __data__?: OrgChartNode<OrganizationGraphDatum>;
}

const props = defineProps<{
  root: OrganizationTreeNode;
}>();

const emit = defineEmits<{
  select: [organization: OrganizationGraphDatum['organization']];
}>();

const ROOT_WIDTH = 250;
const ROOT_HEIGHT = 86;
const NODE_WIDTH = 230;
const NODE_HEIGHT = 82;

const container = ref<HTMLElement | null>(null);

let chart: null | OrgChart<OrganizationGraphDatum> = null;
let fitTimer: number | undefined;
let resizeFrame: number | undefined;
let resizeObserver: null | ResizeObserver = null;
const nodeHoverControllers = new WeakMap<SVGGElement, AbortController>();

function createNodeContent(node: OrgChartNode<OrganizationGraphDatum>): string {
  const { data } = node;
  const label = escapeOrganizationChartHtml(data.label);
  const type = escapeOrganizationChartHtml(getOrganizationTypeLabel(data.type));
  const rootClass = data.level === 0 ? 'organization-org-node--root' : '';

  return `
    <div class="organization-org-node ${rootClass}" title="${label}">
      <div class="organization-org-node__type">${type}</div>
      <div class="organization-org-node__label">${label}</div>
    </div>
  `;
}

function createButtonContent({
  node,
}: {
  node: OrgChartNode<OrganizationGraphDatum>;
}): string {
  const expanded = Boolean(node.children);
  const path = expanded ? 'M5.5 12.5L10 8l4.5 4.5' : 'M5.5 7.5L10 12l4.5-4.5';
  const title = escapeOrganizationChartHtml(
    $t(
      expanded
        ? 'organizations.tree.chart.collapse'
        : 'organizations.tree.chart.expand',
    ),
  );

  return `
    <div class="organization-org-toggle" title="${title}">
      <svg aria-hidden="true" fill="none" viewBox="0 0 20 20">
        <path d="${path}" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
      </svg>
    </div>
  `;
}

function createOrthogonalLink(
  source: OrgChartPoint,
  target: OrgChartPoint,
): string {
  const middleY = target.y + (source.y - target.y) / 2;

  return [
    `M ${source.x} ${source.y}`,
    `V ${middleY}`,
    `H ${target.x}`,
    `V ${target.y}`,
  ].join(' ');
}

function setRelatedLinksActive(
  svg: SVGSVGElement,
  nodeId: string,
  active: boolean,
): void {
  for (const element of svg.querySelectorAll<SVGPathElement>(
    'path.organization-org-link',
  )) {
    const link = element as DataBoundLink;
    const linkNode = link.__data__;

    if (linkNode?.data.id === nodeId || linkNode?.parent?.data.id === nodeId) {
      link.classList.toggle('organization-org-link--active', active);
    }
  }
}

function scheduleFit(delay = 0): void {
  if (fitTimer !== undefined) {
    window.clearTimeout(fitTimer);
  }

  fitTimer = window.setTimeout(() => {
    fitTimer = undefined;
    chart?.fit();
  }, delay);
}

function configureChart(instance: OrgChart<OrganizationGraphDatum>): void {
  if (container.value === null) return;

  instance
    .container(container.value)
    .data(buildOrganizationGraphData([props.root]))
    .nodeId((datum) => datum.id)
    .parentNodeId((datum) => datum.parentId)
    .layout('top')
    .compact(false)
    .defaultFont('Inter, ui-sans-serif, system-ui, -apple-system, sans-serif')
    .svgHeight(container.value.clientHeight)
    .rootMargin(64)
    .nodeWidth((node) => (node.data.level === 0 ? ROOT_WIDTH : NODE_WIDTH))
    .nodeHeight((node) => (node.data.level === 0 ? ROOT_HEIGHT : NODE_HEIGHT))
    .siblingsMargin(() => 42)
    .childrenMargin(() => 94)
    .neighbourMargin(() => 64)
    .compactMarginPair(() => 44)
    .compactMarginBetween(() => 36)
    .nodeButtonWidth(() => 34)
    .nodeButtonHeight(() => 34)
    .nodeButtonX(() => -17)
    .nodeButtonY(() => -17)
    .linkYOffset(0)
    .scaleExtent([0.3, 1.2])
    .duration(220)
    .initialExpandLevel(20)
    .diagonal(createOrthogonalLink)
    .nodeContent(createNodeContent)
    .buttonContent(createButtonContent)
    .onNodeClick((node) => emit('select', node.data.organization))
    .nodeUpdate(function (node) {
      const svg = this.ownerSVGElement;

      nodeHoverControllers.get(this)?.abort();

      const controller = new AbortController();
      nodeHoverControllers.set(this, controller);
      this.classList.add('organization-org-node-group');
      this.addEventListener(
        'mouseenter',
        () => {
          if (svg !== null) setRelatedLinksActive(svg, node.data.id, true);
        },
        { signal: controller.signal },
      );
      this.addEventListener(
        'mouseleave',
        () => {
          if (svg !== null) setRelatedLinksActive(svg, node.data.id, false);
        },
        { signal: controller.signal },
      );
    })
    .linkUpdate(function () {
      this.classList.add('organization-org-link');
    });
}

async function renderChart(): Promise<void> {
  await nextTick();
  if (container.value === null) return;

  chart ??= new OrgChart<OrganizationGraphDatum>();
  configureChart(chart);
  chart.render();
  chart.expandAll();
  scheduleFit(260);
}

function fitChart(): void {
  chart?.fit();
}

function zoomIn(): void {
  chart?.zoomIn();
}

function zoomOut(): void {
  chart?.zoomOut();
}

function expandAll(): void {
  chart?.expandAll();
  scheduleFit(260);
}

function collapseAll(): void {
  chart?.collapseAll();
  scheduleFit(260);
}

function scheduleResize(): void {
  if (resizeFrame !== undefined) cancelAnimationFrame(resizeFrame);

  resizeFrame = requestAnimationFrame(() => {
    resizeFrame = undefined;
    if (chart === null || container.value === null) return;

    chart.svgHeight(container.value.clientHeight).render();
    scheduleFit(240);
  });
}

onMounted(() => {
  void renderChart();
  if (container.value !== null) {
    resizeObserver = new ResizeObserver(scheduleResize);
    resizeObserver.observe(container.value);
  }
});

watch(
  () => [props.root, i18n.global.locale.value],
  () => void renderChart(),
  { deep: true },
);

onBeforeUnmount(() => {
  resizeObserver?.disconnect();
  resizeObserver = null;
  if (resizeFrame !== undefined) cancelAnimationFrame(resizeFrame);
  if (fitTimer !== undefined) window.clearTimeout(fitTimer);
  container.value?.replaceChildren();
  chart = null;
});
</script>

<template>
  <div class="organization-org-chart">
    <div class="organization-org-chart__toolbar">
      <button
        :aria-label="$t('organizations.tree.chart.zoomOut')"
        class="organization-org-chart__button"
        :title="$t('organizations.tree.chart.zoomOut')"
        type="button"
        @click="zoomOut"
      >
        <IconifyIcon icon="lucide:minus" />
      </button>
      <button
        :aria-label="$t('organizations.tree.chart.zoomIn')"
        class="organization-org-chart__button"
        :title="$t('organizations.tree.chart.zoomIn')"
        type="button"
        @click="zoomIn"
      >
        <IconifyIcon icon="lucide:plus" />
      </button>
      <button
        :aria-label="$t('organizations.tree.chart.fit')"
        class="organization-org-chart__button"
        :title="$t('organizations.tree.chart.fit')"
        type="button"
        @click="fitChart"
      >
        <IconifyIcon icon="lucide:scan" />
      </button>
      <div class="organization-org-chart__separator"></div>
      <button
        :aria-label="$t('organizations.tree.chart.expandAll')"
        class="organization-org-chart__button"
        :title="$t('organizations.tree.chart.expandAll')"
        type="button"
        @click="expandAll"
      >
        <IconifyIcon icon="lucide:unfold-vertical" />
      </button>
      <button
        :aria-label="$t('organizations.tree.chart.collapseAll')"
        class="organization-org-chart__button"
        :title="$t('organizations.tree.chart.collapseAll')"
        type="button"
        @click="collapseAll"
      >
        <IconifyIcon icon="lucide:fold-vertical" />
      </button>
    </div>
    <div ref="container" class="organization-org-chart__canvas"></div>
  </div>
</template>

<style scoped>
.organization-org-chart {
  position: relative;
  width: 100%;
  overflow: hidden;
  background:
    radial-gradient(
      circle at 50% 0,
      hsl(var(--primary) / 6%),
      transparent 30rem
    ),
    hsl(var(--background));
  border: 1px solid hsl(var(--border));
  border-radius: 0.875rem;
  box-shadow:
    0 1px 2px rgb(0 0 0 / 4%),
    0 10px 30px rgb(0 0 0 / 5%);
}

.organization-org-chart::before {
  position: absolute;
  inset: 0;
  pointer-events: none;
  content: '';
  background-image:
    linear-gradient(hsl(var(--border) / 12%) 1px, transparent 1px),
    linear-gradient(90deg, hsl(var(--border) / 12%) 1px, transparent 1px);
  background-size: 32px 32px;
  mask-image: linear-gradient(to bottom, rgb(0 0 0 / 36%), transparent 90%);
}

.organization-org-chart__canvas {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 44rem;
  min-height: 38rem;
  overflow: hidden;
}

.organization-org-chart__toolbar {
  position: absolute;
  top: 1rem;
  right: 1rem;
  z-index: 20;
  display: flex;
  gap: 0.25rem;
  align-items: center;
  padding: 0.3rem;
  background: hsl(var(--card) / 94%);
  border: 1px solid hsl(var(--border));
  border-radius: 0.75rem;
  box-shadow: 0 5px 18px rgb(0 0 0 / 10%);
  backdrop-filter: blur(10px);
}

.organization-org-chart__button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 2.125rem;
  height: 2.125rem;
  padding: 0;
  font-size: 1rem;
  color: hsl(var(--muted-foreground));
  cursor: pointer;
  background: transparent;
  border: 0;
  border-radius: 0.5rem;
  transition:
    color 150ms ease,
    background-color 150ms ease,
    box-shadow 150ms ease,
    transform 100ms ease;
}

.organization-org-chart__button:hover {
  color: hsl(var(--primary));
  background: hsl(var(--background));
  box-shadow: 0 2px 8px rgb(0 0 0 / 8%);
}

.organization-org-chart__button:active {
  transform: scale(0.93);
}

.organization-org-chart__separator {
  width: 1px;
  height: 1.25rem;
  margin-inline: 0.125rem;
  background: hsl(var(--border));
}

:deep(.svg-chart-container) {
  display: block;
  width: 100%;
  height: 100%;
}

:deep(.node-rect) {
  fill: transparent;
  stroke: transparent;
}

:deep(.node),
:deep(.organization-org-node-group),
:deep(.node-foreign-object),
:deep(.node-button-foreign-object) {
  overflow: visible;
}

:deep(.organization-org-node) {
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  padding: 0.875rem 1rem;
  color: hsl(var(--foreground));
  cursor: pointer;
  background: hsl(var(--card));
  border: 1.5px solid hsl(var(--border));
  border-radius: 0.875rem;
  box-shadow:
    0 8px 20px rgb(15 23 42 / 7%),
    0 2px 5px rgb(15 23 42 / 5%);
  transition:
    border-color 160ms ease,
    box-shadow 160ms ease,
    transform 160ms ease;
}

:deep(.organization-org-node:hover) {
  z-index: 2;
  border-color: hsl(var(--primary));
  box-shadow:
    0 12px 28px hsl(var(--primary) / 15%),
    0 4px 10px rgb(15 23 42 / 8%);
  transform: translateY(-2px);
}

:deep(.organization-org-node--root) {
  background: linear-gradient(
    180deg,
    hsl(var(--primary) / 7%),
    hsl(var(--card)) 72%
  );
  border: 1.75px solid hsl(var(--primary) / 60%);
}

:deep(.organization-org-node__type) {
  width: 100%;
  min-height: 1.125rem;
  padding-block: 0.1rem;
  margin-bottom: 0.35rem;
  overflow: visible;
  font-size: 0.75rem;
  font-weight: 650;
  line-height: 1.125rem;
  color: hsl(var(--muted-foreground));
  text-align: center;
  letter-spacing: 0.015em;
  white-space: nowrap;
}

:deep(.organization-org-node__label) {
  display: block;
  width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 1rem;
  font-weight: 700;
  line-height: 1.375rem;
  color: hsl(var(--foreground));
  text-align: center;
  white-space: nowrap;
}

:deep(path.organization-org-link) {
  pointer-events: stroke;
  fill: none;
  stroke: hsl(var(--foreground) / 52%);
  stroke-width: 1.75px;
  shape-rendering: geometricprecision;
  transition:
    stroke 150ms ease,
    stroke-width 150ms ease,
    filter 150ms ease;
}

:deep(path.organization-org-link:hover),
:deep(path.organization-org-link--active) {
  filter: drop-shadow(0 0 2px hsl(var(--primary) / 36%));
  stroke: hsl(var(--primary));
  stroke-width: 2.75px;
}

:deep(.organization-org-toggle) {
  box-sizing: border-box;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  color: hsl(var(--muted-foreground));
  cursor: pointer;
  background: hsl(var(--card));
  border: 1.5px solid hsl(var(--border));
  border-radius: 999px;
  box-shadow:
    0 6px 16px rgb(15 23 42 / 12%),
    0 2px 4px rgb(15 23 42 / 6%);
  transition:
    color 150ms ease,
    background-color 150ms ease,
    border-color 150ms ease,
    box-shadow 150ms ease,
    transform 150ms ease;
}

:deep(.organization-org-toggle:hover) {
  color: hsl(var(--primary-foreground));
  background: hsl(var(--primary));
  border-color: hsl(var(--primary));
  box-shadow:
    0 7px 18px hsl(var(--primary) / 25%),
    0 2px 5px rgb(15 23 42 / 8%);
  transform: scale(1.08);
}

:deep(.organization-org-toggle svg) {
  display: block;
  width: 1.05rem;
  height: 1.05rem;
}
</style>
