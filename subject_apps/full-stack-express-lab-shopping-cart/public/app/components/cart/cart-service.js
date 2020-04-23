"use strict";

function CartService ($http) {
    const self = this;

    // get request to server
    self.getAllItems = () => {
        return $http({
            method: "GET",
            url: "/cart-items"
        });
    };
};

angular.module("CartApp").service("CartService", CartService);