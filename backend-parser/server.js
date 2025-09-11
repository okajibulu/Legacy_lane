const express = require('express');
const fs = require('fs');
const path = require('path');
const glob = require('glob');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());

app.get('/parse', (req, res) => {
  const flutterLibPath = path.resolve(__dirname, '../lib');
  console.log('Scanning path:', flutterLibPath);

  const dartFiles = glob.sync(`${flutterLibPath}/**/*.dart`);

  console.log('Found Dart files:', dartFiles); // Debug log

  const parsed = dartFiles.map(file => {
    const content = fs.readFileSync(file, 'utf8');
    return {
      filename: path.basename(file),
      filepath: file,
      content: content
    };
  });

  res.json(parsed);
});

app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
