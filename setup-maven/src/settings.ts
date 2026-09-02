import * as core from '@actions/core'
import fs from 'node:fs/promises'
import os from 'node:os'
import path from 'node:path'

export interface SettingsInputs {
  /** JSON array of server definitions. */
  servers?: string

  /** JSON array of mirror definitions. */
  mirrors?: string

  /** JSON array of one-key property objects. */
  properties?: string

  /** Target file. Defaults to `<home>/.m2/settings.xml`. */
  path?: string

  /** When false, an existing file is kept untouched. */
  override?: boolean
}

type XmlValue = string | number | boolean | XmlObject

interface XmlObject {
  [name: string]: XmlValue
}

function escapeXml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;')
}

function renderElement(name: string, value: XmlValue): string {
  if (typeof value === 'object' && value !== null) {
    const children = Object.entries(value)
      .map(([childName, childValue]) => renderElement(childName, childValue))
      .join('')
    return `<${name}>${children}</${name}>`
  }

  return `<${name}>${escapeXml(String(value))}</${name}>`
}

function parseArray(inputName: string, json: string): XmlObject[] {
  let parsed: unknown
  try {
    parsed = JSON.parse(json)
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error)
    throw new Error(`Invalid JSON in the ${inputName} input: ${reason}`, {
      cause: error
    })
  }

  if (!Array.isArray(parsed)) {
    throw new Error(`The ${inputName} input must be a JSON array.`)
  }

  return parsed as XmlObject[]
}

function renderList(
  containerName: string,
  itemName: string,
  inputName: string,
  json: string
): string {
  const items = parseArray(inputName, json)
  const rendered = items.map((item) => renderElement(itemName, item)).join('')
  return `<${containerName}>${rendered}</${containerName}>`
}

/**
 * Writes a Maven settings.xml from the action inputs.
 *
 * @param inputs The settings-related action inputs.
 * @returns The path of the written file, or null when nothing was written.
 */
export async function writeSettings(
  inputs: SettingsInputs
): Promise<string | null> {
  if (!inputs.servers && !inputs.mirrors && !inputs.properties) {
    return null
  }

  const settingsPath =
    inputs.path || path.join(os.homedir(), '.m2', 'settings.xml')

  const exists = await fs.access(settingsPath).then(
    () => true,
    () => false
  )
  if (exists && inputs.override === false) {
    core.info(
      `Not writing ${settingsPath}: the file exists and settings-override is false.`
    )
    return null
  }

  const sections = ['<interactiveMode>false</interactiveMode>']

  if (inputs.servers) {
    sections.push(
      renderList('servers', 'server', 'settings-servers', inputs.servers)
    )
  }

  if (inputs.mirrors) {
    sections.push(
      renderList('mirrors', 'mirror', 'settings-mirrors', inputs.mirrors)
    )
  }

  if (inputs.properties) {
    const properties: XmlObject = Object.assign(
      {},
      ...parseArray('settings-properties', inputs.properties)
    )
    sections.push(
      renderElement('profiles', {
        profile: {
          id: '_properties_',
          activation: { activeByDefault: true },
          properties
        }
      })
    )
  }

  const document = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">',
    ...sections,
    '</settings>',
    ''
  ].join('\n')

  await fs.mkdir(path.dirname(settingsPath), { recursive: true })
  await fs.writeFile(settingsPath, document)

  // Let the post step know which file to remove when the job ends.
  core.saveState('settingsPath', settingsPath)
  core.info(`Wrote Maven settings to ${settingsPath}`)

  return settingsPath
}
