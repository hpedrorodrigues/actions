import * as core from '@actions/core'
import fs from 'node:fs/promises'

/**
 * The post-step logic for the action: removes the settings.xml written by the
 * main step, so credentials do not persist on the runner or land in caches.
 *
 * @returns Resolves when the cleanup is complete.
 */
export async function run(): Promise<void> {
  try {
    const settingsPath = core.getState('settingsPath')
    if (!settingsPath) {
      return
    }

    await fs.rm(settingsPath, { force: true })
    core.info(`Removed the generated Maven settings at ${settingsPath}`)
  } catch (error) {
    // A cleanup failure must not fail the job.
    if (error instanceof Error) core.warning(error.message)
  }
}
