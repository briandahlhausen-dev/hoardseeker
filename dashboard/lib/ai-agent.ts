import Anthropic from '@anthropic-ai/sdk'
import type { News, NewsItem } from './schemas'
import { getConfig } from './data'

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
})

interface RawFeedItem {
  headline: string
  source: string
  sourceUrl: string
  publishedAt: string
  rawText?: string
}

export async function summariseNewsItems(items: RawFeedItem[]): Promise<NewsItem[]> {
  if (items.length === 0) return []

  const config = getConfig()
  const context = `Dashboard: ${config.title}. Subtitle: ${config.subtitle}.`

  const itemsText = items
    .map(
      (item, i) =>
        `[${i + 1}] SOURCE: ${item.source}\nHEADLINE: ${item.headline}\nPUBLISHED: ${item.publishedAt}\nURL: ${item.sourceUrl}\nCONTENT: ${item.rawText ?? '(no body text provided)'}`
    )
    .join('\n\n---\n\n')

  const message = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 4096,
    system: `You are an intelligence analyst summarising news items for a monitoring dashboard. Context: ${context}.

    For each news item, write a 2-4 sentence factual summary in the style of an intelligence brief: precise, present-tense where possible, no opinion.

    Return a JSON array where each element has:
    - "id": "news_<index>" (1-based)
    - "headline": the original headline (unchanged)
    - "source": the source name
    - "sourceUrl": the URL
    - "publishedAt": the ISO timestamp
    - "summary": your 2-4 sentence summary
    - "category": one of: "official", "field", "response", "spread", "intelligence", "milestone"

    Return ONLY valid JSON, no markdown fences.`,
    messages: [
      {
        role: 'user',
        content: `Summarise these ${items.length} news items:\n\n${itemsText}`,
      },
    ],
  })

  const text = message.content[0].type === 'text' ? message.content[0].text : '[]'

  try {
    const parsed = JSON.parse(text) as NewsItem[]
    return parsed
  } catch {
    console.error('Failed to parse AI response:', text)
    return []
  }
}

export async function buildNewsUpdate(rawItems: RawFeedItem[]): Promise<News> {
  const summarised = await summariseNewsItems(rawItems)
  return {
    lastUpdated: new Date().toISOString(),
    items: summarised,
  }
}
