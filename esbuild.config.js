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
  external: [
    '@fullcalendar/core', 
    '@fullcalendar/daygrid', 
    '@fullcalendar/timegrid', 
    '@fullcalendar/list', 
    '@fullcalendar/bootstrap5', 
    '@fullcalendar/interaction', 
    'jquery', 
    'bootstrap'
  ],
};

async function build() {
  try {
    if (watchMode) {
      const ctx = await esbuild.context(buildOptions);
      await ctx.watch();
    } else {
      await esbuild.build(buildOptions);
    }
  } catch (error) {
    process.exit(1);
  }
}

build().catch((error) => {
  process.exit(1);
});
