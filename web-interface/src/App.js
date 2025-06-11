import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { BrowserRouter as Router, Route, Link, Routes } from 'react-router-dom';
import ToolStore from './ToolStore';
import './App.css';

function ToolManager() {
  const [tools, setTools] = useState([]);
  const [toolUrl, setToolUrl] = useState('');
  const [toolName, setToolName] = useState('');
  const [toolDescription, setToolDescription] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    axios.get('http://localhost:8000/tools')
      .then(response => setTools(response.data.tools))
      .catch(err => setError('Failed to fetch tools'));
  }, []);

  const addTool = () => {
    if (!toolName || !toolUrl) {
      setError('Please provide both name and URL');
      return;
    }
    axios.post('http://localhost:8000/tools', { name: toolName, url: toolUrl, description: toolDescription })
      .then(response => {
        setTools([...tools, response.data]);
        setToolName('');
        setToolUrl('');
        setToolDescription('');
        setError('');
      })
      .catch(err => setError('Failed to add tool'));
  };

  const deleteTool = (name) => {
    axios.delete(`http://localhost:8000/tools/${name}`)
      .then(() => {
        setTools(tools.filter(tool => tool.name !== name));
      })
      .catch(err => setError('Failed to delete tool'));
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">OpenAPI Tool Manager</h1>
      {error && <p className="text-red-500">{error}</p>}
      <div className="mb-4">
        <input
          type="text"
          placeholder="Tool Name"
          value={toolName}
          onChange={(e) => setToolName(e.target.value)}
          className="border p-2 mr-2"
        />
        <input
          type="text"
          placeholder="Tool URL (e.g., http://localhost:8000)"
          value={toolUrl}
          onChange={(e) => setToolUrl(e.target.value)}
          className="border p-2 mr-2"
        />
        <input
          type="text"
          placeholder="Tool Description"
          value={toolDescription}
          onChange={(e) => setToolDescription(e.target.value)}
          className="border p-2 mr-2"
        />
        <button
          onClick={addTool}
          className="bg-blue-500 text-white p-2 rounded"
        >
          Add Tool
        </button>
      </div>
      <h2 className="text-xl font-semibold mb-2">Configured Tools</h2>
      <ul className="list-disc pl-5">
        {tools.map(tool => (
          <li key={tool.name} className="mb-2">
            {tool.name} ({tool.url}) - {tool.description}
            <button
              onClick={() => deleteTool(tool.name)}
              className="ml-2 text-red-500"
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

function App() {
  return (
    <Router>
      <nav className="bg-gray-800 p-4">
        <ul className="flex space-x-4 text-white">
          <li>
            <Link to="/" className="hover:underline">Tool Manager</Link>
          </li>
          <li>
            <Link to="/store" className="hover:underline">Tool Store</Link>
          </li>
        </ul>
      </nav>
      <Routes>
        <Route path="/" element={<ToolManager />} />
        <Route path="/store" element={<ToolStore />} />
      </Routes>
    </Router>
  );
}

export default App;