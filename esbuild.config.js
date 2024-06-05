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
  plugins: [sassPlugin()],
  loader: { '.js': 'jsx' },
};

async function build() {
  const context = await esbuild.context(buildOptions);

  if (watchMode) {
    context.watch();
    console.log('watching...');
  } else {
    await context.rebuild();
    console.log('Rebuild complete.');
  }
}

build().catch(() => process.exit(1));
