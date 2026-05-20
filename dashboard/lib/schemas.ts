import { z } from 'zod'

// ── Severity enums ──────────────────────────────────────────────
export const SeveritySchema = z.enum(['critical', 'elevated', 'stable'])
export const StatusSeveritySchema = z.enum(['crit', 'warn', 'ok', 'info'])
export const MarkerStatusSchema = z.enum(['active', 'cluster', 'imported', 'monitoring'])
export const TrendSchema = z.enum(['up', 'down', 'flat'])
export const TimelineSeveritySchema = z.enum(['crit', 'warn', 'ok', 'info'])

// ── Config schema ──────────────────────────────────────────────
export const MetricConfigSchema = z.object({
  id: z.string(),
  label: z.string(),
  threshold: z.number().optional(),
  thresholdDirection: z.enum(['above', 'below']).optional(),
})

export const IndicatorConfigSchema = z.object({
  id: z.string(),
  label: z.string(),
})

export const NewsSourceSchema = z.object({
  name: z.string(),
  url: z.string().url(),
  type: z.enum(['official', 'wire', 'specialty']),
})

export const SecondaryLayerSchema = z.object({
  label: z.string(),
  icon: z.enum(['chevron', 'circle']),
})

export const ConfigSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
  status: z.object({
    label: z.string(),
    severity: StatusSeveritySchema,
  }),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  mapBounds: z.tuple([
    z.tuple([z.number(), z.number()]),
    z.tuple([z.number(), z.number()]),
  ]),
  mapCenter: z.tuple([z.number(), z.number()]),
  mapZoom: z.number(),
  metrics: z.array(MetricConfigSchema),
  indicators: z.array(IndicatorConfigSchema),
  markerSizeField: z.string(),
  markerSizeRange: z.tuple([z.number(), z.number()]),
  secondaryLayers: z.record(SecondaryLayerSchema).optional(),
  newsSources: z.array(NewsSourceSchema),
})

// ── Situation schema ───────────────────────────────────────────
export const MetricStateSchema = z.object({
  value: z.union([z.number(), z.string()]),
  subscript: z.string().optional(),
  sparkline: z.array(z.number()).optional(),
  thresholdBreached: z.boolean().optional(),
})

export const LocationDetailsSchema = z.object({
  firstReported: z.string(),
  lastUpdate: z.string(),
  population: z.string().optional(),
  healthCapacity: z.string().optional(),
  notes: z.string().optional(),
})

export const LocationSchema = z.object({
  id: z.string(),
  name: z.string(),
  lat: z.number(),
  lng: z.number(),
  status: MarkerStatusSchema,
  caseCount: z.number(),
  details: LocationDetailsSchema.optional(),
})

export const SecondaryMarkerSchema = z.object({
  id: z.string(),
  name: z.string(),
  lat: z.number(),
  lng: z.number(),
  status: z.string().optional(),
})

export const IndicatorStateSchema = z.object({
  value: z.union([z.number(), z.string()]),
  severity: SeveritySchema,
  trend: TrendSchema.optional(),
  note: z.string().optional(),
})

export const SituationSchema = z.object({
  lastUpdated: z.string().datetime(),
  metrics: z.record(MetricStateSchema),
  locations: z.array(LocationSchema),
  secondaryMarkers: z.record(z.array(SecondaryMarkerSchema)).optional(),
  indicators: z.record(IndicatorStateSchema),
})

// ── Timeline schema ────────────────────────────────────────────
export const TimelineEventSchema = z.object({
  id: z.string(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  title: z.string(),
  description: z.string(),
  severity: TimelineSeveritySchema,
  category: z.string(),
})

export const TimelineSchema = z.array(TimelineEventSchema)

// ── News schema ────────────────────────────────────────────────
export const NewsItemSchema = z.object({
  id: z.string(),
  headline: z.string(),
  source: z.string(),
  sourceUrl: z.string().url(),
  publishedAt: z.string().datetime(),
  summary: z.string(),
  category: z.string(),
})

export const NewsSchema = z.object({
  lastUpdated: z.string().datetime(),
  items: z.array(NewsItemSchema),
})

// ── Exported types ─────────────────────────────────────────────
export type Config = z.infer<typeof ConfigSchema>
export type MetricConfig = z.infer<typeof MetricConfigSchema>
export type IndicatorConfig = z.infer<typeof IndicatorConfigSchema>
export type NewsSource = z.infer<typeof NewsSourceSchema>
export type Situation = z.infer<typeof SituationSchema>
export type MetricState = z.infer<typeof MetricStateSchema>
export type Location = z.infer<typeof LocationSchema>
export type IndicatorState = z.infer<typeof IndicatorStateSchema>
export type Severity = z.infer<typeof SeveritySchema>
export type StatusSeverity = z.infer<typeof StatusSeveritySchema>
export type MarkerStatus = z.infer<typeof MarkerStatusSchema>
export type Trend = z.infer<typeof TrendSchema>
export type TimelineEvent = z.infer<typeof TimelineEventSchema>
export type NewsItem = z.infer<typeof NewsItemSchema>
export type News = z.infer<typeof NewsSchema>
