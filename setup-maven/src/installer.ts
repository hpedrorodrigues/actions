import * as core from '@actions/core'
import * as exec from '@actions/exec'
import * as toolCache from '@actions/tool-cache'
import path from 'node:path'

const downloadBaseUrl = 'https://archive.apache.org/dist/maven'

export interface InstallOptions {
  /**
   * Base URL of a Maven-repository-layout mirror (e.g., an Artifact Registry
   * remote repository of Maven Central). When set, the distribution is
   * downloaded from
   * `<mirrorUrl>/org/apache/maven/apache-maven/<version>/apache-maven-<version>-bin.tar.gz`.
   */
  mirrorUrl?: string

  /** Bearer token used to authenticate against the mirror. */
  mirrorToken?: string

  /**
   * When true (the default), a preinstalled Maven that matches the requested
   * version is reused instead of downloading. When false, a preinstalled
   * Maven fails the action.
   */
  skipIfInstalled?: boolean
}

interface PreinstalledMaven {
  version: string
  home: string
}

function downloadUrl(version: string, mirrorUrl?: string): string {
  if (mirrorUrl) {
    const base = mirrorUrl.replace(/\/+$/, '')
    return `${base}/org/apache/maven/apache-maven/${version}/apache-maven-${version}-bin.tar.gz`
  }

  const majorVersion = version.split('.')[0]
  return `${downloadBaseUrl}/maven-${majorVersion}/${version}/binaries/apache-maven-${version}-bin.tar.gz`
}

/**
 * Finds a Maven installation that is already on the PATH.
 *
 * @returns The installed version and home, or null when mvn is not found.
 */
async function findPreinstalledMaven(): Promise<PreinstalledMaven | null> {
  try {
    const output = await exec.getExecOutput('mvn', ['--version'], {
      silent: true,
      ignoreReturnCode: true
    })

    const version = output.stdout.match(/^Apache Maven (\S+)/m)?.[1]
    const home = output.stdout.match(/^Maven home: (.+)$/m)?.[1]

    if (version && home) {
      return { version, home: home.trim() }
    }
  } catch {
    // mvn is not on the PATH.
  }

  return null
}

/**
 * Installs the given version of Apache Maven, using the runner tool cache
 * when possible.
 *
 * @param version The Maven version to install (e.g., 3.9.16).
 * @param options Optional mirror and preinstalled-Maven configuration.
 * @returns The path to the Maven installation.
 */
export async function installMaven(
  version: string,
  options: InstallOptions = {}
): Promise<string> {
  if (!/^\d+\.\d+\.\d+$/.test(version)) {
    throw new Error(
      `Invalid Maven version "${version}". Expected a full version such as 3.9.16.`
    )
  }

  const preinstalled = await findPreinstalledMaven()
  if (preinstalled) {
    if (options.skipIfInstalled === false) {
      throw new Error(
        `Maven ${preinstalled.version} is already installed at ${preinstalled.home} and skip-if-installed is false. ` +
          'Remove Maven from the runner image, or set skip-if-installed to true.'
      )
    }

    if (preinstalled.version === version) {
      core.info(
        `Found Maven ${version} already installed at ${preinstalled.home}`
      )
      return preinstalled.home
    }

    core.info(
      `Ignoring preinstalled Maven ${preinstalled.version}: version ${version} was requested.`
    )
  }

  const cached = toolCache.find('maven', version)
  if (cached) {
    core.info(`Found Maven ${version} in the tool cache: ${cached}`)
    return cached
  }

  const url = downloadUrl(version, options.mirrorUrl)
  const auth = options.mirrorToken ? `Bearer ${options.mirrorToken}` : undefined

  core.info(`Downloading Maven ${version} from ${url}`)
  const archive = await toolCache.downloadTool(url, undefined, auth)
  const extracted = await toolCache.extractTar(archive)

  const installed = await toolCache.cacheDir(
    path.join(extracted, `apache-maven-${version}`),
    'maven',
    version
  )
  core.info(`Cached Maven ${version} at ${installed}`)

  return installed
}
