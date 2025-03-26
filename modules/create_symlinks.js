process.chdir(__dirname);
const path = require("path");
const fs = require("fs");
const child_process = require("child_process");

let not_utils_dir = "";

const contents_dir = "../../";
for (let pack of fs.readdirSync(contents_dir)) {
  const pkg_file = path.join(contents_dir, pack, "package.json");
  if (fs.existsSync(pkg_file)) {
    const data = fs.readFileSync(pkg_file).toString();
    let id = "";
    try {
      id = JSON.parse(data).id;
    } catch {}

    if (id == "not_utils") {
      not_utils_dir = path.join(pkg_file, "../modules");
      break;
    }
  }
}

async function create_symlink(dest, dir) {
  await fs.promises.rmdir(dest).catch(() => {});
  return child_process.execSync(`mklink /D "${path.resolve(dest)}" "${path.resolve(dir)}"`).toString();
}

create_symlink("not_utils", not_utils_dir).then(console.log);
