const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Setup CLI prompt
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('Enter the module name (e.g. communityblog, musicroom, games/card): ', (moduleName) => {
  const basePath = path.join(__dirname, 'src', moduleName);
  const files = [
    {
      name: 'RoomHome.jsx',
      content: `import React from 'react';

export default function RoomHome() {
  return (
    <div>
      <h2>${moduleName} Home</h2>
      <p>Welcome to the ${moduleName} room!</p>
    </div>
  );
}
`
    },
    {
      name: 'RoomSettings.jsx',
      content: `import React from 'react';

export default function RoomSettings() {
  return (
    <div>
      <h2>${moduleName} Settings</h2>
      <p>Configure your ${moduleName} preferences here.</p>
    </div>
  );
}
`
    }
  ];

  // Create folder if it doesn't exist
  if (!fs.existsSync(basePath)) {
    fs.mkdirSync(basePath, { recursive: true });
    console.log(`✅ Created folder: ${basePath}`);
  } else {
    console.log(`⚠️ Folder already exists: ${basePath}`);
  }

  // Create files with boilerplate
  files.forEach(file => {
    const filePath = path.join(basePath, file.name);
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, file.content);
      console.log(`📄 Created file: ${file.name}`);
    } else {
      console.log(`⚠️ File already exists: ${file.name}`);
    }
  });

  rl.close();
});
