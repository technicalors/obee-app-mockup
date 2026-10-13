declare module 'd3-org-chart' {
  export interface OrgChartPoint {
    x: number;
    y: number;
  }

  export interface OrgChartNode<TData> {
    _children?: OrgChartNode<TData>[];
    children?: OrgChartNode<TData>[];
    data: TData;
    depth: number;
    height: number;
    id?: string;
    parent?: null | OrgChartNode<TData>;
    width: number;
  }

  export interface OrgChartState<TData> {
    compact: boolean;
    data: TData[];
    id: string;
    layout: 'bottom' | 'left' | 'right' | 'top';
  }

  export class OrgChart<TData = Record<string, unknown>> {
    buttonContent(
      callback: (context: {
        node: OrgChartNode<TData>;
        state: OrgChartState<TData>;
      }) => string,
    ): this;

    childrenMargin(callback: (node: OrgChartNode<TData>) => number): this;

    collapseAll(): this;

    compact(value: boolean): this;

    compactMarginBetween(callback: (node: OrgChartNode<TData>) => number): this;

    compactMarginPair(callback: (node: OrgChartNode<TData>) => number): this;

    container(value: HTMLElement | string): this;

    data(value: TData[]): this;

    defaultFont(value: string): this;

    diagonal(
      callback: (
        source: OrgChartPoint,
        target: OrgChartPoint,
        middle?: OrgChartPoint,
        offsets?: { sy?: number },
      ) => string,
    ): this;

    duration(value: number): this;

    expandAll(): this;

    fit(): this;

    getChartState(): OrgChartState<TData>;

    initialExpandLevel(value: number): this;

    layout(value: 'bottom' | 'left' | 'right' | 'top'): this;

    linkUpdate(
      callback: (
        this: SVGPathElement,
        node: OrgChartNode<TData>,
        index: number,
        elements: SVGPathElement[],
      ) => void,
    ): this;

    linkYOffset(value: number): this;

    neighbourMargin(
      callback: (
        first: OrgChartNode<TData>,
        second: OrgChartNode<TData>,
      ) => number,
    ): this;

    nodeButtonHeight(callback: (node: OrgChartNode<TData>) => number): this;

    nodeButtonWidth(callback: (node: OrgChartNode<TData>) => number): this;

    nodeButtonX(callback: (node: OrgChartNode<TData>) => number): this;

    nodeButtonY(callback: (node: OrgChartNode<TData>) => number): this;

    nodeContent(
      callback: (
        node: OrgChartNode<TData>,
        index: number,
        elements: unknown[],
        state: OrgChartState<TData>,
      ) => string,
    ): this;

    nodeHeight(callback: (node: OrgChartNode<TData>) => number): this;

    nodeId(callback: (datum: TData) => string): this;

    nodeUpdate(
      callback: (
        this: SVGGElement,
        node: OrgChartNode<TData>,
        index: number,
        elements: SVGGElement[],
      ) => void,
    ): this;

    nodeWidth(callback: (node: OrgChartNode<TData>) => number): this;

    onNodeClick(callback: (node: OrgChartNode<TData>) => void): this;

    parentNodeId(callback: (datum: TData) => null | string | undefined): this;

    render(): this;

    rootMargin(value: number): this;

    scaleExtent(value: [number, number]): this;

    siblingsMargin(callback: (node: OrgChartNode<TData>) => number): this;

    svgHeight(value: number): this;

    zoomIn(): this;

    zoomOut(): this;
  }
}
