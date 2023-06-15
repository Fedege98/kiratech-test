import React, { useState, useEffect } from "react";
import axios from "axios";

function App() {
  const [tasks, setTasks] = useState([]);
  const [newTask, setNewTask] = useState("");

  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    const response = await axios.get("http://localhost:5000/tasks");
    setTasks(response.data);
  };

  const addTask = async () => {
    await axios.post("http://localhost:5000/tasks", { text: newTask });
    setNewTask("");
    fetchTasks();
  };

  return (
    <div>
      <h1>Todo List</h1>
      <input
        value={newTask}
        onChange={e => setNewTask(e.target.value)}
      />
      <button onClick={addTask}>Add Task</button>
      <ul>
        {tasks.map(task => (
          <li key={task._id}>{task.text}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
