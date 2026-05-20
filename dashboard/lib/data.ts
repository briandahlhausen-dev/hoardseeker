import path from 'path'
import fs from 'fs'
import {
  ConfigSchema,
  SituationSchema,
  TimelineSchema,
  NewsSchema,
  type Config,
  type Situation,
  type TimelineEvent,
  type News,
} from './schemas'

const DATA_DIR = path.join(process.cwd(), 'data')

function readJson<T>(filename: string, schema: { parse: (v: unknown) => T }): T {
  const filePath = path.join(DATA_DIR, filename)
  const raw = fs.readFileSync(filePath, 'utf-8')
  return schema.parse(JSON.parse(raw))
}

export function getConfig(): Config {
  return readJson('config.json', ConfigSchema)
}

export function getSituation(): Situation {
  return readJson('situation.json', SituationSchema)
}

export function getTimeline(): TimelineEvent[] {
  return readJson('timeline.json', TimelineSchema)
}

export function getNews(): News {
  return readJson('news.json', NewsSchema)
}

export function writeSituation(situation: Situation): void {
  const filePath = path.join(DATA_DIR, 'situation.json')
  fs.writeFileSync(filePath, JSON.stringify(situation, null, 2), 'utf-8')
}

export function writeNews(news: News): void {
  const filePath = path.join(DATA_DIR, 'news.json')
  fs.writeFileSync(filePath, JSON.stringify(news, null, 2), 'utf-8')
}

