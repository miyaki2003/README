const esbuild = require('esbuild');
const sassPlugin = require('esbuild-plugin-sass');
const watchMode = process.argv.includes('--watch');

console.log('Starting esbuild...');

let buildOptions = {
  entryPoints: {
    application: 'app/javascript/application.js',
    fullcalendar: 'app/javascript/fullcalendar.js',
    reminders: 'app/javascript/reminders.js'
  },
  bundle: true,
  outdir: './app/assets/builds',
  sourcemap: true,
  plugins: [sassPlugin(), {
    name: 'on-end',
    setup(build) {
      build.onEnd(result => {
        if (result.errors.length > 0) {
          console.error('Build failed:', result.errors);
        } else {
          console.log('Build succeeded:', result);
        }
      });
    }
  }],
  loader: { '.js': 'jsx' },
};

async function build() {
  try {
    const context = await esbuild.context(buildOptions);
    if (watchMode) {
      console.log('Entering watch mode...');
      await context.watch();
      console.log('Watching for changes...');
    } else {
      console.log('Rebuilding...');
      await context.rebuild();
      console.log('Rebuild complete.');
    }
  } catch (error) {
    console.error('Build error:', error);
  }
}

build().then(() => {
  console.log('Build script executed.');
}).catch(error => {
  console.error('Error during build execution:', error);
});
