import { getConfig, getSituation, getTimeline, getNews } from '@/lib/data'
import DashboardClient from '@/components/dashboard/DashboardClient'

export const dynamic = 'force-dynamic'
export const revalidate = 0

export default function HomePage() {
  const config = getConfig()
  const situation = getSituation()
  const timeline = getTimeline()
  const news = getNews()

  return (
    <DashboardClient
      config={config}
      situation={situation}
      timeline={timeline}
      news={news}
    />
  )
}
