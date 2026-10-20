import type { VxeTableGridOptions } from '@vben/plugins/vxe-table';

import type { ComponentPropsMap, ComponentType } from './component';

import { h } from 'vue';

import { IconifyIcon } from '@vben/icons';
import {
  setupVbenVxeTable,
  useVbenVxeGrid as useGrid,
} from '@vben/plugins/vxe-table';

import { Button, Image, Tag, Tooltip } from 'ant-design-vue';

import { useVbenForm } from './form';

type CellTagValue = boolean | number | string;

interface CellTagOption {
  color: string;
  label: string;
  value: CellTagValue;
}

interface CellTagsAttrs<
  Row extends Record<string, unknown> = Record<string, unknown>,
> {
  emptyLabel?: string;
  getColor: (item: unknown, row: Row) => string;
  getItems: (row: Row) => readonly unknown[];
  getKey: (item: unknown, index: number) => number | string;
  getLabel: (item: unknown, row: Row) => string;
}

interface CellOperationOption<
  Row extends Record<string, unknown> = Record<string, unknown>,
> {
  code: string;
  danger?: boolean;
  icon?: string;
  label: string;
  type?: 'default' | 'link' | 'primary' | 'text';
  visible?: (row: Row) => boolean;
}

interface CellOperationAttrs<
  Row extends Record<string, unknown> = Record<string, unknown>,
> {
  onClick: (code: string, row: Row) => void;
}

setupVbenVxeTable({
  configVxeTable: (vxeUI) => {
    vxeUI.setConfig({
      grid: {
        align: 'center',
        border: false,
        columnConfig: {
          resizable: true,
        },
        minHeight: 180,
        formConfig: {
          // 全局禁用vxe-table的表单配置，使用formOptions
          enabled: false,
        },
        proxyConfig: {
          autoLoad: true,
          response: {
            result: 'items',
            total: 'total',
            list: 'items',
          },
          showActiveMsg: true,
          showResponseMsg: false,
        },
        round: true,
        showOverflow: true,
        size: 'small',
      } as VxeTableGridOptions,
    });

    // 表格配置项可以用 cellRender: { name: 'CellImage' },
    vxeUI.renderer.add('CellImage', {
      renderTableDefault(renderOpts, params) {
        const { props } = renderOpts;
        const { column, row } = params;
        return h(Image, { src: row[column.field], ...props });
      },
    });

    // 表格配置项可以用 cellRender: { name: 'CellLink' },
    vxeUI.renderer.add('CellLink', {
      renderTableDefault(renderOpts) {
        const { props } = renderOpts;
        return h(
          Button,
          { size: 'small', type: 'link' },
          { default: () => props?.text },
        );
      },
    });

    vxeUI.renderer.add('CellTag', {
      renderTableDefault(renderOpts, params) {
        const options = renderOpts.options as readonly CellTagOption[];
        const { column, row } = params;
        const value = row[column.field] as CellTagValue;
        const option = options.find((item) => item.value === value);

        if (!option) {
          throw new Error(`Missing CellTag option for ${String(value)}.`);
        }

        return h(Tag, { color: option.color }, { default: () => option.label });
      },
    });

    vxeUI.renderer.add('CellTags', {
      renderTableDefault(renderOpts, params) {
        const attrs = renderOpts.attrs as CellTagsAttrs;
        const row = params.row as Record<string, unknown>;
        const items = attrs.getItems(row);

        if (items.length === 0) {
          return h(
            'span',
            { class: 'text-muted-foreground' },
            attrs.emptyLabel,
          );
        }

        return h(
          'div',
          { class: 'flex flex-wrap justify-center gap-1' },
          items.map((item, index) =>
            h(
              Tag,
              {
                color: attrs.getColor(item, row),
                key: attrs.getKey(item, index),
              },
              { default: () => attrs.getLabel(item, row) },
            ),
          ),
        );
      },
    });

    vxeUI.renderer.add('CellOperation', {
      renderTableDefault(renderOpts, params) {
        const attrs = renderOpts.attrs as CellOperationAttrs;
        const options = renderOpts.options as readonly CellOperationOption[];
        const row = params.row as Record<string, unknown>;

        return h(
          'div',
          { class: 'flex items-center justify-center gap-1.5' },
          options
            .map((option) => {
              const isAllowed = option.visible ? option.visible(row) : true;
              const isDisabled = !isAllowed;

              const button = h(
                Button,
                {
                  'aria-label': option.label,
                  class: option.icon
                    ? 'inline-flex size-7 items-center justify-center p-0'
                    : undefined,
                  danger: option.danger && !isDisabled,
                  disabled: isDisabled,
                  icon: option.icon
                    ? h(IconifyIcon, {
                        class: 'size-4',
                        icon: option.icon,
                      })
                    : undefined,
                  key: option.code,
                  onClick: isDisabled ? undefined : () => attrs.onClick(option.code, row),
                  size: 'small',
                  type: option.type ?? 'link',
                },
                option.icon ? undefined : { default: () => option.label },
              );

              return option.icon
                ? h(
                    Tooltip,
                    { key: option.code, title: option.label },
                    () => button,
                  )
                : button;
            }),
        );
      },
    });

    // 这里可以自行扩展 vxe-table 的全局配置，比如自定义格式化
    // vxeUI.formats.add
  },
  useVbenForm,
});

export const useVbenVxeGrid = <T extends object>(
  ...rest: Parameters<typeof useGrid<T, ComponentType, ComponentPropsMap>>
) => useGrid<T, ComponentType, ComponentPropsMap>(...rest);

export type * from '@vben/plugins/vxe-table';
