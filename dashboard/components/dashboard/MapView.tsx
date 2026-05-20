'use client'

import { useEffect, useRef, useState, useCallback } from 'react'
import type { Map as MapLibreMap, GeoJSONSource } from 'maplibre-gl'
import type { Config, Situation, Location } from '@/lib/schemas'

const STATUS_COLORS: Record<string, string> = {
  active: '#ff2e4c',
  cluster: '#ffb020',
  imported: '#4fc3ff',
  monitoring: '#6b7280',
}

interface MapViewProps {
  config: Config
  situation: Situation
  onLocationSelect: (location: Location | null) => void
}

function logSize(count: number, minSize: number, maxSize: number, minCount: number, maxCount: number): number {
  if (maxCount === minCount) return (minSize + maxSize) / 2
  const log = Math.log(count - minCount + 1) / Math.log(maxCount - minCount + 1)
  return minSize + log * (maxSize - minSize)
}

const LAYER_TOGGLES = ['borders', 'sites'] as const

export default function MapView({ config, situation, onLocationSelect }: MapViewProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const mapRef = useRef<MapLibreMap | null>(null)
  const [ready, setReady] = useState(false)
  const [activeLayers, setActiveLayers] = useState<Set<string>>(new Set(LAYER_TOGGLES))
  const [hoveredId, setHoveredId] = useState<string | null>(null)

  const mapStyle = process.env.NEXT_PUBLIC_MAP_STYLE ||
    'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json'

  useEffect(() => {
    if (!containerRef.current || mapRef.current) return

    let map: MapLibreMap

    import('maplibre-gl').then(({ Map, NavigationControl }) => {
      const [[swLng, swLat], [neLng, neLat]] = config.mapBounds
      map = new Map({
        container: containerRef.current!,
        style: mapStyle,
        center: config.mapCenter,
        zoom: config.mapZoom,
        maxBounds: [[swLng - 10, swLat - 10], [neLng + 10, neLat + 10]],
        attributionControl: false,
        pitchWithRotate: false,
        dragRotate: false,
      })

      map.addControl(new NavigationControl({ showCompass: false }), 'top-left')
      mapRef.current = map

      map.on('load', () => {
        // Primary location markers
        const locationsGeoJSON: GeoJSON.FeatureCollection = {
          type: 'FeatureCollection',
          features: situation.locations.map((loc) => ({
            type: 'Feature',
            id: loc.id,
            properties: {
              id: loc.id,
              name: loc.name,
              status: loc.status,
              caseCount: loc.caseCount,
              color: STATUS_COLORS[loc.status] ?? '#d4d4d4',
            },
            geometry: { type: 'Point', coordinates: [loc.lng, loc.lat] },
          })),
        }

        map.addSource('locations', { type: 'geojson', data: locationsGeoJSON })

        const counts = situation.locations.map((l) => l.caseCount)
        const minCount = Math.min(...counts)
        const maxCount = Math.max(...counts)
        const [minSize, maxSize] = config.markerSizeRange

        // Glow layer
        map.addLayer({
          id: 'locations-glow',
          type: 'circle',
          source: 'locations',
          paint: {
            'circle-radius': situation.locations.reduce(
              (expr: unknown[], loc) => {
                const r = logSize(loc.caseCount, minSize, maxSize, minCount, maxCount)
                return [...expr, loc.id, r * 1.8]
              },
              ['match', ['get', 'id']] as unknown[]
            ).concat([minSize * 1.8]) as maplibregl.ExpressionSpecification,
            'circle-color': ['get', 'color'],
            'circle-opacity': 0.15,
            'circle-blur': 1,
          },
        })

        // Main circle layer
        map.addLayer({
          id: 'locations-circles',
          type: 'circle',
          source: 'locations',
          paint: {
            'circle-radius': situation.locations.reduce(
              (expr: unknown[], loc) => {
                const r = logSize(loc.caseCount, minSize, maxSize, minCount, maxCount)
                return [...expr, loc.id, r]
              },
              ['match', ['get', 'id']] as unknown[]
            ).concat([minSize]) as maplibregl.ExpressionSpecification,
            'circle-color': ['get', 'color'],
            'circle-opacity': 0.8,
            'circle-stroke-width': 1.5,
            'circle-stroke-color': ['get', 'color'],
          },
        })

        // Labels
        map.addLayer({
          id: 'locations-labels',
          type: 'symbol',
          source: 'locations',
          layout: {
            'text-field': ['get', 'name'],
            'text-font': ['Open Sans Regular', 'Arial Unicode MS Regular'],
            'text-size': 10,
            'text-offset': [0, 1.8],
            'text-anchor': 'top',
          },
          paint: {
            'text-color': '#ffffff',
            'text-halo-color': '#0a0d12',
            'text-halo-width': 1.5,
          },
        })

        // Border crossings layer
        if (situation.secondaryMarkers?.borders) {
          const bordersGeoJSON: GeoJSON.FeatureCollection = {
            type: 'FeatureCollection',
            features: situation.secondaryMarkers.borders.map((b) => ({
              type: 'Feature',
              id: b.id,
              properties: { id: b.id, name: b.name, status: b.status ?? 'open' },
              geometry: { type: 'Point', coordinates: [b.lng, b.lat] },
            })),
          }
          map.addSource('borders', { type: 'geojson', data: bordersGeoJSON })
          map.addLayer({
            id: 'borders-layer',
            type: 'circle',
            source: 'borders',
            paint: {
              'circle-radius': 5,
              'circle-color': '#ffb020',
              'circle-stroke-width': 1.5,
              'circle-stroke-color': '#ffb020',
              'circle-opacity': 0.7,
            },
          })
        }

        // Response sites layer
        if (situation.secondaryMarkers?.sites) {
          const sitesGeoJSON: GeoJSON.FeatureCollection = {
            type: 'FeatureCollection',
            features: situation.secondaryMarkers.sites.map((s) => ({
              type: 'Feature',
              id: s.id,
              properties: { id: s.id, name: s.name },
              geometry: { type: 'Point', coordinates: [s.lng, s.lat] },
            })),
          }
          map.addSource('sites', { type: 'geojson', data: sitesGeoJSON })
          map.addLayer({
            id: 'sites-layer',
            type: 'circle',
            source: 'sites',
            paint: {
              'circle-radius': 4,
              'circle-color': '#2dd4a4',
              'circle-stroke-width': 1,
              'circle-stroke-color': '#2dd4a4',
              'circle-opacity': 0.8,
            },
          })
        }

        // Click handler
        map.on('click', 'locations-circles', (e) => {
          if (!e.features?.[0]) return
          const id = e.features[0].properties?.id as string
          const loc = situation.locations.find((l) => l.id === id) ?? null
          onLocationSelect(loc)
        })

        map.on('mouseenter', 'locations-circles', () => {
          map.getCanvas().style.cursor = 'pointer'
        })
        map.on('mouseleave', 'locations-circles', () => {
          map.getCanvas().style.cursor = ''
        })

        setReady(true)
      })
    })

    return () => {
      map?.remove()
      mapRef.current = null
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // Toggle secondary layers
  useEffect(() => {
    if (!mapRef.current || !ready) return
    const map = mapRef.current

    if (map.getLayer('borders-layer')) {
      map.setLayoutProperty('borders-layer', 'visibility', activeLayers.has('borders') ? 'visible' : 'none')
    }
    if (map.getLayer('sites-layer')) {
      map.setLayoutProperty('sites-layer', 'visibility', activeLayers.has('sites') ? 'visible' : 'none')
    }
  }, [activeLayers, ready])

  const toggleLayer = useCallback((id: string) => {
    setActiveLayers((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }, [])

  return (
    <div className="relative w-full h-full border border-[#1f2937]" style={{ borderRadius: 2 }}>
      {/* Map container */}
      <div ref={containerRef} className="absolute inset-0" style={{ borderRadius: 2 }} />

      {/* Layer toggles — top right */}
      {config.secondaryLayers && (
        <div className="absolute top-2 right-2 z-10 flex flex-col gap-1">
          {Object.entries(config.secondaryLayers).map(([id, layer]) => (
            <button
              key={id}
              onClick={() => toggleLayer(id)}
              className="flex items-center gap-1.5 px-2 py-1 text-[9px] font-mono-ui tracking-widest uppercase border transition-colors"
              style={{
                background: activeLayers.has(id) ? 'rgba(79,195,255,0.15)' : 'rgba(10,13,18,0.9)',
                borderColor: activeLayers.has(id) ? '#4fc3ff' : '#1f2937',
                color: activeLayers.has(id) ? '#4fc3ff' : '#d4d4d4',
                borderRadius: 2,
              }}
            >
              <span
                className="w-1.5 h-1.5 rounded-full"
                style={{ background: activeLayers.has(id) ? '#4fc3ff' : '#6b7280' }}
              />
              {layer.label}
            </button>
          ))}
        </div>
      )}

      {/* Legend — bottom left */}
      <div
        className="absolute bottom-2 left-2 z-10 px-2 py-1.5 border border-[#1f2937]"
        style={{ background: 'rgba(10,13,18,0.92)', borderRadius: 2 }}
      >
        <div className="text-[8px] font-mono-ui text-[#d4d4d4]/50 tracking-widest uppercase mb-1">Status</div>
        {Object.entries(STATUS_COLORS).map(([status, color]) => (
          <div key={status} className="flex items-center gap-1.5 mb-0.5">
            <span className="w-2 h-2 rounded-full" style={{ background: color }} />
            <span className="text-[9px] font-mono-ui uppercase tracking-wide" style={{ color }}>
              {status}
            </span>
          </div>
        ))}
      </div>

      {/* Loading overlay */}
      {!ready && (
        <div className="absolute inset-0 flex items-center justify-center bg-[#0a0d12]/80 z-20">
          <span className="text-[10px] font-mono-ui text-[#4fc3ff] tracking-widest animate-pulse">
            INITIALISING MAP...
          </span>
        </div>
      )}
    </div>
  )
}
