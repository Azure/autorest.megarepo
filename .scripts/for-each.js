var cp = require("child_process");
var fs = require("fs");
var path = require("path");

function read(filename) {
  const txt = fs.readFileSync(filename, "utf8")
    .replace(/\r/gm, "")
    .replace(/\n/gm, "«")
    .replace(/\/\*.*?\*\//gm, "")
    .replace(/«/gm, "\n")
    .replace(/\s+\/\/.*/g, "");
  return JSON.parse(txt);
}

const repo = `${__dirname}/..`;

const rush = read(`${repo}/rush.json`);
const pjs = {};

function forEachProject(onEach) {
  // load all the projects
  for (const each of rush.projects) {
    const packageName = each.packageName;
    const projectFolder = path.resolve(`${repo}/${each.projectFolder}`);
    const project = require(`${projectFolder}/package.json`);
    onEach(packageName, projectFolder, project);
  }
}

function npmForEach(cmd) {
  let count = 0;
  let exitCode = 0;
  const result = {};
  const procs = [];
  const t1 = process.uptime() * 100;
  forEachProject((name, location, project) => {
    // checks for the script first
    if (project.scripts[cmd]) {
      count++;
      const proc = cp.spawn("npm", ["--silent", "run", cmd], { cwd: location, shell: true, stdio: "inherit" });
      procs.push(proc);
      result[name] = {
        name, location, project, proc,
      };
    }
  });

  procs.forEach(proc => proc.on("close", (code, signal) => {
    count--;
    exitCode += code;

    if (count === 0) {
      const t2 = process.uptime() * 100;

      console.log('---------------------------------------------------------');
      if (exitCode !== 0) {
        console.log(`  Done : command '${cmd}' - ${Math.floor(t2 - t1) / 100} s -- Errors ${exitCode} `)
      } else {
        console.log(`  Done : command '${cmd}' - ${Math.floor(t2 - t1) / 100} s -- No Errors `)
      }
      console.log('---------------------------------------------------------');
      process.exit(exitCode);
    }
  }));

  return result;
}

module.exports.forEachProject = forEachProject;
module.exports.npm = npmForEach;
