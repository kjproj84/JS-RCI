"use strict";

const cart = {
    templateUrl: "app/components/cart/cart.html",
    controller: ["CartService", function(CartService) {
        const vm =this;

        vm.getCart = () => {
            CartService.getAllItems().then((response) => {
                // console.log(response.data);
                return vm.listItems = response.data;
            });
        };
    }]
};

angular.module("CartApp").component("cart", cart);