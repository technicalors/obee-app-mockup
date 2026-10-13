<script setup lang="ts">
import type { OrgChartNode, OrgChartPoint } from 'd3-org-chart';

import type { DepartmentTreeNode } from './department-tree';

import type { Company, Department } from '#/api';

import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';

import { IconifyIcon } from '@vben/icons';

import { OrgChart } from 'd3-org-chart';

import { $t } from '#/locales';

interface OrganizationChartDatum {
  childCount: number;
  department?: Department;
  id: string;
  kind: 'company' | 'department';
  label: string;
  level: number;
  parentId: null | string;
}

interface DataBoundLink extends SVGPathElement {
  __data__?: OrgChartNode<OrganizationChartDatum>;
}

const props = defineProps<{
  company: Company;
  tree: DepartmentTreeNode[];
}>();

const emit = defineEmits<{
  select: [department: Department];
}>();

const COMPANY_WIDTH = 250;
const COMPANY_HEIGHT = 76;
const NODE_WIDTH = 230;
const NODE_HEIGHT = 82;

const container = ref<HTMLElement | null>(null);

let chart: null | OrgChart<OrganizationChartDatum> = null;
let fitTimer: number | undefined;
let resizeFrame: number | undefined;
let resizeObserver: null | ResizeObserver = null;
const nodeHoverControllers = new WeakMap<SVGGElement, AbortController>();

function escapeHtml(value: string): string {
  const entities: Record<string, string> = {
    '"': '&quot;',
    '&': '&amp;',
    "'": '&#039;',
    '<': '&lt;',
    '>': '&gt;',
  };

  return value.replaceAll(
    /[&<>"']/g,
    (character) => entities[character] ?? character,
  );
}

function createChartData(): OrganizationChartDatum[] {
  const companyId = `company:${String(props.company.id)}`;

  const result: OrganizationChartDatum[] = [
    {
      childCount: props.tree.length,
      id: companyId,
      kind: 'company',
      label: props.company.name,
      level: 0,
      parentId: null,
    },
  ];

  function appendNode(
    node: DepartmentTreeNode,
    parentId: string,
    level: number,
  ): void {
    const id = `department:${String(node.department.id)}`;

    result.push({
      childCount: node.children.length,
      department: node.department,
      id,
      kind: 'department',
      label: node.department.name,
      level,
      parentId,
    });

    for (const child of node.children) {
      appendNode(child, id, level + 1);
    }
  }

  for (const node of props.tree) {
    appendNode(node, companyId, 1);
  }

  return result;
}

function getNodeTypeLabel(data: OrganizationChartDatum): string {
  if (data.kind === 'company') {
    return $t('page.departments.tree.chart.companyNode');
  }

  if (data.level === 1) {
    return $t('page.departments.tree.chart.directDepartment');
  }

  return $t('page.departments.tree.chart.departmentLevel', {
    level: data.level,
  });
}

function createNodeContent(node: OrgChartNode<OrganizationChartDatum>): string {
  const data = node.data;
  const label = escapeHtml(data.label);
  const typeLabel = escapeHtml(getNodeTypeLabel(data));

  let kindClass = 'department-org-node--department';

  if (data.kind === 'company') {
    kindClass = 'department-org-node--company';
  } else if (data.level === 1) {
    kindClass = 'department-org-node--primary';
  }

  return `
    <div
      class="department-org-node ${kindClass}"
      title="${label}"
    >
      <div class="department-org-node__type">
        ${typeLabel}
      </div>

      <div class="department-org-node__label">
        ${label}
      </div>
    </div>
  `;
}

function createButtonContent({
  node,
}: {
  node: OrgChartNode<OrganizationChartDatum>;
}): string {
  const expanded = Boolean(node.children);

  const path = expanded ? 'M5.5 12.5L10 8l4.5 4.5' : 'M5.5 7.5L10 12l4.5-4.5';

  const title = $t(
    expanded
      ? 'page.departments.tree.chart.collapse'
      : 'page.departments.tree.chart.expand',
  );

  return `
    <div
      class="department-org-toggle"
      title="${title}"
      data-expanded="${String(expanded)}"
    >
      <svg
        aria-hidden="true"
        fill="none"
        viewBox="0 0 20 20"
      >
        <path
          d="${path}"
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
        />
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
  const links = svg.querySelectorAll<SVGPathElement>(
    'path.department-org-link',
  );

  for (const element of links) {
    const link = element as DataBoundLink;
    const linkNode = link.__data__;

    const incoming = linkNode?.data.id === nodeId;
    const outgoing = linkNode?.parent?.data.id === nodeId;

    if (incoming || outgoing) {
      link.classList.toggle('department-org-link--active', active);
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

function configureChart(instance: OrgChart<OrganizationChartDatum>): void {
  if (container.value === null) {
    return;
  }

  instance
    .container(container.value)
    .data(createChartData())
    .nodeId((datum) => datum.id)
    .parentNodeId((datum) => datum.parentId)
    .layout('top')
    .compact(false)
    .defaultFont('Inter, ui-sans-serif, system-ui, -apple-system, sans-serif')
    .svgHeight(container.value.clientHeight)
    .rootMargin(64)
    .nodeWidth((node) =>
      node.data.kind === 'company' ? COMPANY_WIDTH : NODE_WIDTH,
    )
    .nodeHeight((node) =>
      node.data.kind === 'company' ? COMPANY_HEIGHT : NODE_HEIGHT,
    )
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
    .onNodeClick((node) => {
      const department = node.data.department;

      if (department !== undefined) {
        emit('select', department);
      }
    })
    .nodeUpdate(function (node) {
      const svg = this.ownerSVGElement;

      nodeHoverControllers.get(this)?.abort();

      const controller = new AbortController();
      nodeHoverControllers.set(this, controller);

      this.classList.add('department-org-node-group');

      this.addEventListener(
        'mouseenter',
        () => {
          if (svg !== null) {
            setRelatedLinksActive(svg, node.data.id, true);
          }
        },
        { signal: controller.signal },
      );

      this.addEventListener(
        'mouseleave',
        () => {
          if (svg !== null) {
            setRelatedLinksActive(svg, node.data.id, false);
          }
        },
        { signal: controller.signal },
      );
    })
    .linkUpdate(function () {
      this.classList.add('department-org-link');
    });
}

async function renderChart(): Promise<void> {
  await nextTick();

  if (container.value === null) {
    return;
  }

  if (chart === null) {
    chart = new OrgChart<OrganizationChartDatum>();
  }

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
  if (resizeFrame !== undefined) {
    cancelAnimationFrame(resizeFrame);
  }

  resizeFrame = requestAnimationFrame(() => {
    resizeFrame = undefined;

    if (chart === null || container.value === null) {
      return;
    }

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
  () => [props.company.id, props.company.name, props.tree],
  () => {
    void renderChart();
  },
  {
    deep: true,
  },
);

onBeforeUnmount(() => {
  resizeObserver?.disconnect();
  resizeObserver = null;

  if (resizeFrame !== undefined) {
    cancelAnimationFrame(resizeFrame);
  }

  if (fitTimer !== undefined) {
    window.clearTimeout(fitTimer);
  }

  container.value?.replaceChildren();
  chart = null;
});
</script>

<template>
  <div class="department-org-chart">
    <div class="department-org-chart__toolbar">
      <button
        class="department-org-chart__button"
        :title="$t('page.departments.tree.chart.zoomOut')"
        type="button"
        @click="zoomOut"
      >
        <IconifyIcon icon="lucide:minus" />
      </button>

      <button
        class="department-org-chart__button"
        :title="$t('page.departments.tree.chart.zoomIn')"
        type="button"
        @click="zoomIn"
      >
        <IconifyIcon icon="lucide:plus" />
      </button>

      <button
        class="department-org-chart__button"
        :title="$t('page.departments.tree.chart.fit')"
        type="button"
        @click="fitChart"
      >
        <IconifyIcon icon="lucide:scan" />
      </button>

      <div class="department-org-chart__separator"></div>

      <button
        class="department-org-chart__button"
        :title="$t('page.departments.tree.chart.expandAll')"
        type="button"
        @click="expandAll"
      >
        <IconifyIcon icon="lucide:unfold-vertical" />
      </button>

      <button
        class="department-org-chart__button"
        :title="$t('page.departments.tree.chart.collapseAll')"
        type="button"
        @click="collapseAll"
      >
        <IconifyIcon icon="lucide:fold-vertical" />
      </button>
    </div>

    <div ref="container" class="department-org-chart__canvas"></div>
  </div>
</template>

<style scoped>
.department-org-chart {
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

.department-org-chart::before {
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

.department-org-chart__canvas {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 44rem;
  min-height: 38rem;
  overflow: hidden;
}

.department-org-chart__toolbar {
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

.department-org-chart__button {
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

.department-org-chart__button:hover {
  color: hsl(var(--primary));
  background: hsl(var(--background));
  box-shadow: 0 2px 8px rgb(0 0 0 / 8%);
}

.department-org-chart__button:active {
  transform: scale(0.93);
}

.department-org-chart__separator {
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
:deep(.department-org-node-group),
:deep(.node-foreign-object),
:deep(.node-button-foreign-object) {
  overflow: visible;
}

:deep(.department-org-node) {
  position: relative;
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

:deep(.department-org-node:hover) {
  z-index: 2;
  border-color: hsl(var(--primary));
  box-shadow:
    0 12px 28px hsl(var(--primary) / 15%),
    0 4px 10px rgb(15 23 42 / 8%);
  transform: translateY(-2px);
}

:deep(.department-org-node--company) {
  color: hsl(var(--primary-foreground));
  cursor: default;
  background: linear-gradient(
    135deg,
    hsl(var(--primary)),
    hsl(var(--primary) / 84%)
  );
  border: 2px solid hsl(var(--primary));
  box-shadow:
    0 14px 28px hsl(var(--primary) / 24%),
    0 4px 10px rgb(15 23 42 / 10%);
}

:deep(.department-org-node--primary) {
  background: linear-gradient(
    180deg,
    hsl(var(--primary) / 7%),
    hsl(var(--card)) 72%
  );
  border: 1.75px solid hsl(var(--primary) / 60%);
}

:deep(.department-org-node__type) {
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

:deep(.department-org-node--company .department-org-node__type) {
  color: hsl(var(--primary-foreground) / 78%);
}

:deep(.department-org-node__label) {
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

:deep(.department-org-node--company .department-org-node__label) {
  font-size: 1.125rem;
  line-height: 1.5rem;
  color: hsl(var(--primary-foreground));
}

:deep(path.department-org-link) {
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

:deep(path.department-org-link:hover),
:deep(path.department-org-link--active) {
  filter: drop-shadow(0 0 2px hsl(var(--primary) / 36%));
  stroke: hsl(var(--primary));
  stroke-width: 2.75px;
}

:deep(.department-org-toggle) {
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

:deep(.department-org-toggle:hover) {
  color: hsl(var(--primary-foreground));
  background: hsl(var(--primary));
  border-color: hsl(var(--primary));
  box-shadow:
    0 7px 18px hsl(var(--primary) / 25%),
    0 2px 5px rgb(15 23 42 / 8%);
  transform: scale(1.08);
}

:deep(.department-org-toggle svg) {
  display: block;
  width: 1.05rem;
  height: 1.05rem;
}
</style>
