import * as core from '@actions/core'
import path from 'node:path'
import { installMaven } from './installer.js'

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

    const mavenHome = await installMaven(version, { mirrorUrl, mirrorToken })

    core.addPath(path.join(mavenHome, 'bin'))
    core.exportVariable('MAVEN_HOME', mavenHome)

    core.setOutput('path', mavenHome)
    core.setOutput('version', version)
  } catch (error) {
    if (error instanceof Error) core.setFailed(error.message)
  }
}
