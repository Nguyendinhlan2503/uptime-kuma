/**
 * Vite plugin to replace absolute asset paths with relative paths
 * This allows the server-side HTML injection to properly prefix them with base path
 */
export function basePathPlugin() {
    return {
        name: 'base-path-plugin',
        renderChunk(code, chunk, options) {
            // Replace absolute paths like /assets/... with relative paths ./assets/...
            // This allows the server-side HTML injection to properly prefix them
            // Match patterns like: "/assets/file.js" or '/assets/file.js'
            const modified = code.replace(
                /(["'])\/assets\/([^"']+)\1/g,
                '$1./assets/$2$1'
            );
            return {
                code: modified,
                map: null, // We don't need source maps for this transformation
            };
        },
    };
}

