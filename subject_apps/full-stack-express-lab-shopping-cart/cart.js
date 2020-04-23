"use strict"
const express = require("express");
const cart = express.Router();

const items = [
    {
        id: 0,
        item: "Almond Milk",
        price: "$4",
        quantity: 1,
    },
    {
        id: 1,
        item: "Seitan",
        price: "$12",
        quantity: 2,
    },
    {
        id: 2,
        item: "Bananas",
        price: "$.89",
        quantity: 5,
    }
];

//send info
cart.get("/cart-items" , (req, res) => {
    console.log("items");
    res.json(items);
});

//recieved info
cart.post("/cart-items" , (req, res) => {
    console.log(req.body);
    items.push(req.body);
    res.json(items);
});

// is an updates by id and send new data
cart.put("/cart-items/:id", (req, res) => {
    console.log(req.params.id)
    console.log(req.body)
    items[req.params.id] = req.body; 
    res.json(items); 
});

//deletes info
cart.delete("/cart-items/:id", (req, res) => {
    console.log(req.params.id)
    console.log(req.body)
    items.splice(req.params.id, 1);
    res.json(items); 
});

module.exports = cart;