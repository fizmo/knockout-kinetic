knockout-kinetic
================

A KnockoutJS plugin for KineticJS.

Overview
--------

This package is designed to enable using the data-binding awesomeness of
[KnockoutJS][1] with the HTML5 Canvas drawing wizardy of [KineticJS][2]. Fun
features include:

* Declartive Canvas elements: create a hierarchy of Kinetic nodes inline
  in your HTML, with no JavaScript!
* Kinetic Node data-binding: declartively bind properties of your Kinetic nodes
  to your ViewModel, without manually subscribing to observables!

Usage
-----

While you can use regular HTML elements as placeholders for your Canvas, it is
recommended that you use [virtual elements][3] instead:

    <!DOCTYPE html>
    <html>
      <head>
        <title>A Knockout/Kinetic example</title>
        <script type="text/javascript" src="kinetic-v3.9.8.min.js"></script>
        <script type="text/javascript" src="knockout-2.1.0.js"></script>
        <script type="text/javascript" src="../knockout-kinetic.js"></script>
      </head>
      <body>
        <!-- 
        This example is from the 'Rect' tutorial:
        http://www.html5canvastutorials.com/kineticjs/html5-canvas-kineticjs-rect-tutorial/
        -->
        <div id="container">
          <!-- Look, ma! No JavaScript! -->
          <!-- ko Kinetic.Stage: { width: 578, height: 200 } -->
          <!--     ko Kinetic.Layer: { } -->
          <!--         ko Kinetic.Rect: { x: 239, y: 75, width: 100, height: 50, fill: "#00D2FF", stroke: "black", strokeWidth: 4 } -->
          <!--         /ko -->
          <!--     /ko -->
          <!-- /ko -->
        </div>
        <script type="text/javascript">
            // Ok, a *little* JavaScript...
            ko.applyBindings();
        </script>
    </html>

This example doesn't use any actual observables, but they are fully supported.

Feedback
--------

The best way to provide feedback is via the [github issues page][4], as I don't
actively monitor either the Kinetic or Knockout forums. Pull requests are a
great way to get my attention. :)

[1]: http://knockoutjs.com/
[2]: http://www.kineticjs.com/
[3]: http://knockoutjs.com/documentation/custom-bindings-for-virtual-elements.html
[4]: https://github.com/christophercurrie/knockout-kinetic/issues