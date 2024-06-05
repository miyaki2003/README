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
  try {
    console.log('Starting build process...');

    if (watchMode) {
      console.log('Entering watch mode...');
      const ctx = await esbuild.context(buildOptions);
      await ctx.watch();
      console.log('watching...');
    } else {
      console.log('Rebuilding...');
      await esbuild.build(buildOptions);
      console.log('Rebuild complete.');
    }
  } catch (error) {
    console.error('Build process failed:', error);
    process.exit(1);
  }
}

build().catch((error) => {
  console.error('Build script error:', error);
  process.exit(1);
});
