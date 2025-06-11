import React, { useState, useEffect } from 'react';
import axios from 'axios';

function ToolStore() {
  const [tools, setTools] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    axios.get('http://localhost:8000/tools')
      .then(response => setTools(response.data.tools))
      .catch(err => setError('Failed to fetch tools'));
  }, []);

  const handleDownload = (name) => {
    axios.post(`http://localhost:8000/tools/${name}/download`)
      .then(() => {
        alert(`Download recorded for ${name}. Visit the GitHub repository to download the tool files.`);
      })
      .catch(err => setError('Failed to record download'));
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">OpenAPI Tool Store</h1>
      {error && <p className="text-red-500">{error}</p>}
      <p className="mb-4">
        Browse available tools below. To download a tool, click the Download button and follow the instructions in the{' '}
        <a href="https://github.com/mianderson2469/openapi-tool-server" className="text-blue-500 underline">
          GitHub repository
        </a>.
      </p>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {tools.map(tool => (
          <div key={tool.name} className="border p-4 rounded shadow">
            <h2 className="text-xl font-semibold">{tool.name}</h2>
            <p className="text-gray-600">{tool.description || 'No description available'}</p>
            <p className="text-sm text-gray-500">Downloads: {tool.downloads}</p>
            <p className="text-sm text-gray-500">
              URL: <a href={tool.url} className="text-blue-500 underline">{tool.url}</a>
            </p>
            <button
              onClick={() => handleDownload(tool.name)}
              className="mt-2 bg-green-500 text-white p-2 rounded"
            >
              Download
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ToolStore;