/**
 * Main AngularJS Web Application
 */
var app = angular.module('companyx_028', [
  'ngRoute'
]);

/**
 * Configure the Routes
 */
app.config(['$routeProvider', function ($routeProvider) {
  $routeProvider
    // Home
    .when("/", {templateUrl: "partials/home.html", controller: "PageCtrl"})
    // Pages
    .when("/clients", {templateUrl: "clients.jsp", controller: "PageCtrl"})
    .when("/vehicles", {templateUrl: "vehicles.jsp", controller: "PageCtrl"})
    .when("/pois", {templateUrl: "pois.jsp", controller: "PageCtrl"})
    .when("/formularioclientes", {templateUrl: "formularioclientes.jsp", controller: "PageCtrl"})
    .when("/formularioviajes", {templateUrl: "formularioviajes.jsp", controller: "PageCtrl"})
    .when("/formulariotiempomedio", {templateUrl: "formulariotiempomedio.jsp", controller: "PageCtrl"})
    .when("/formulariotiempoviajes", {templateUrl: "formulariotiempoviajes.jsp", controller: "PageCtrl"})
    .when("/formularioaltausuarios", {templateUrl: "formularioaltausuarios.jsp", controller: "PageCtrl"})
    .when("/formulariomodificarusuarios", {templateUrl: "formulariomodificarusuarios.jsp", controller: "PageCtrl"})
    // else 404
    .otherwise("/404", {templateUrl: "partials/404.html", controller: "PageCtrl"});
}]);

/**
 * Controls Pages
 */
app.controller('PageCtrl', function (/* $scope, $location, $http */) {
  console.log("Page Controller reporting for duty.");

  // Activates the Carousel
  $('.carousel').carousel({
    interval: 5000
  });

  // Activates Tooltips for Social Links
  $('.tooltip-social').tooltip({
    selector: "a[data-toggle=tooltip]"
  })
});