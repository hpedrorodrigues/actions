// See: https://rollupjs.org/introduction/

import commonjs from '@rollup/plugin-commonjs'
import nodeResolve from '@rollup/plugin-node-resolve'
import typescript from '@rollup/plugin-typescript'

/**
 * @param {string} input
 * @param {string} file
 */
const bundle = (input, file) => ({
  input,
  output: {
    esModule: true,
    file,
    format: 'es',
    sourcemap: true
  },
  plugins: [typescript(), nodeResolve({ preferBuiltins: true }), commonjs()]
})

const config = [
  bundle('src/index.ts', 'dist/index.js'),
  bundle('src/post.ts', 'dist/post.js')
]

export default config
