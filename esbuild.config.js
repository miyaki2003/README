const esbuild = require('esbuild');
const sassPlugin = require('esbuild-plugin-sass');
const watchMode = process.argv.includes('--watch');

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
  const context = await esbuild.context(buildOptions);
  if (watchMode) {
    await context.watch();
    console.log('watching...');
  } else {
    await context.rebuild();
  }
}

build()
