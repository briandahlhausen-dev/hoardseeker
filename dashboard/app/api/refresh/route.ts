import { NextRequest, NextResponse } from 'next/server'
import { getNews, writeNews } from '@/lib/data'
import { buildNewsUpdate } from '@/lib/ai-agent'

export const runtime = 'nodejs'
export const maxDuration = 300

export async function GET(req: NextRequest) {
  const authHeader = req.headers.get('authorization')
  const expected = `Bearer ${process.env.CRON_SECRET}`

  if (authHeader !== expected) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const currentNews = getNews()

    // In production, fetch from actual RSS/news feeds here.
    // For now, regenerate summaries for existing headlines as a demonstration.
    const rawItems = currentNews.items.map((item) => ({
      headline: item.headline,
      source: item.source,
      sourceUrl: item.sourceUrl,
      publishedAt: item.publishedAt,
    }))

    const updated = await buildNewsUpdate(rawItems)
    writeNews(updated)

    return NextResponse.json({
      success: true,
      itemCount: updated.items.length,
      timestamp: updated.lastUpdated,
    })
  } catch (err) {
    console.error('[refresh] error:', err)
    return NextResponse.json(
      { error: 'Refresh failed', detail: String(err) },
      { status: 500 }
    )
  }
}
