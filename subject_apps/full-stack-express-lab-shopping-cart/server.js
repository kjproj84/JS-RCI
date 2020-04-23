"use strict";
const express = require("express");
const app = express();
const cart = require("./cart.js");

app.use(express.static("./public"));
app.use(express.json());
app.use("/", cart);

const port = 3000;
app.listen(port, () => {
    console.log(`Server is running PORT: ${port}`);  
});