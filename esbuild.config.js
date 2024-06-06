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

if (watchMode) {
  buildOptions.watch = {
    onRebuild(error, result) {
      if (error) console.error('watch build failed:', error);
      else console.log('watch build succeeded:', result);
    },
  };
}

esbuild.build(buildOptions).catch(() => process.exit(1));