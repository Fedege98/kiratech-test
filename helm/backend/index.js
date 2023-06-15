const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

mongoose.connect("mongodb://localhost:27017/todolist", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const taskSchema = new mongoose.Schema({
  text: String,
});

const Task = mongoose.model("Task", taskSchema);

app.use(cors());
app.use(express.json());

app.get("/tasks", async (req, res) => {
  const tasks = await Task.find();
  res.send(tasks);
});

app.post("/tasks", async (req, res) => {
  const newTask = new Task({ text: req.body.text });
  await newTask.save();
  res.send(newTask);
});

app.listen(5000, () => console.log("Server listening on port 5000"));
