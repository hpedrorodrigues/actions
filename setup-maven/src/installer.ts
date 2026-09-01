import * as core from '@actions/core'
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
 * Installs the given version of Apache Maven, using the runner tool cache
 * when possible.
 *
 * @param version The Maven version to install (e.g., 3.9.16).
 * @param options Optional mirror configuration.
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
