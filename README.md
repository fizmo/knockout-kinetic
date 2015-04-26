knockout-konva
================

A KonvaJS plugin for KnockoutJS.

Overview
--------

This is a fork of [Christoper Curries Knockout-Kinetic plugin](5) for working with Konva JS

This package is designed to enable using the data-binding awesomeness of
[KnockoutJS][1] with the HTML5 Canvas drawing wizardy of [KonvaJS][2]. Fun
features include:

* Declartive Canvas elements: create a hierarchy of Konva nodes inline
  in your HTML, with no JavaScript!
* Konva Node data-binding: declartively bind properties of your Konva nodes
  to your ViewModel, without manually subscribing to observables!

Usage
-----

While you can use regular HTML elements as placeholders for your Canvas, it is
recommended that you use [virtual elements][3] instead:

    <!DOCTYPE html>
    <html>
      <head>
        <title>A Knockout/Konva example</title>
        <script type="text/javascript" src="konva-v3.9.8.min.js"></script>
        <script type="text/javascript" src="knockout-2.1.0.js"></script>
        <script type="text/javascript" src="../knockout-konva.js"></script>
      </head>
      <body>
        <!-- 
        This example is from the 'Rect' tutorial:
        http://www.html5canvastutorials.com/konvajs/html5-canvas-konvajs-rect-tutorial/
        -->
        <div id="container">
          <!-- Look, ma! No JavaScript! -->
          <!-- ko Konva.Stage: { width: 578, height: 200 } -->
          <!--     ko Konva.Layer: { } -->
          <!--         ko Konva.Rect: { x: 239, y: 75, width: 100, height: 50, fill: "#00D2FF", stroke: "black", strokeWidth: 4 } -->
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
actively monitor either the Konva or Knockout forums. Pull requests are a
great way to get my attention. :)

[1]: http://knockoutjs.com/
[2]: http://konvajs.github.io/
[3]: http://knockoutjs.com/documentation/custom-bindings-for-virtual-elements.html
[4]: https://github.com/mcintyre321/knockout-konva/issues
[5]: https://github.com/christophercurrie/knockout-kinetic/issues
