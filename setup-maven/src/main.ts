import * as core from '@actions/core'
import path from 'node:path'
import { installMaven } from './installer.js'
import { writeSettings } from './settings.js'

/**
 * The main function for the action.
 *
 * @returns Resolves when the action is complete.
 */
export async function run(): Promise<void> {
  try {
    const version = core.getInput('version', { required: true })
    const mirrorUrl = core.getInput('mirror-url')
    const mirrorToken = core.getInput('mirror-token')

    if (mirrorToken) core.setSecret(mirrorToken)

    const mavenHome = await installMaven(version, {
      mirrorUrl,
      mirrorToken,
      skipIfInstalled:
        core.getInput('skip-if-installed').toLowerCase() !== 'false'
    })

    await writeSettings({
      servers: core.getInput('settings-servers'),
      mirrors: core.getInput('settings-mirrors'),
      properties: core.getInput('settings-properties'),
      path: core.getInput('settings-path'),
      override: core.getInput('settings-override').toLowerCase() !== 'false'
    })

    core.addPath(path.join(mavenHome, 'bin'))
    core.exportVariable('MAVEN_HOME', mavenHome)

    core.setOutput('path', mavenHome)
    core.setOutput('version', version)
  } catch (error) {
    if (error instanceof Error) core.setFailed(error.message)
  }
}
