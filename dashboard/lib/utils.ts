export function getDayCount(startDate: string): number {
  const start = new Date(startDate)
  const now = new Date()
  const diff = now.getTime() - start.getTime()
  return Math.floor(diff / (1000 * 60 * 60 * 24)) + 1
}

export function severityToColor(severity: 'crit' | 'warn' | 'ok' | 'info'): string {
  const map: Record<string, string> = {
    crit: '#ff2e4c',
    warn: '#ffb020',
    ok: '#2dd4a4',
    info: '#4fc3ff',
  }
  return map[severity] ?? '#d4d4d4'
}
