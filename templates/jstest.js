/*global TestCase PACKAGE fail assertTrue*/
/*jslint newcap:false*/
TestCase("CLASSNAMETest", {
    testConstructor: function () {
        var instance = new PACKAGE.CLASSNAME();
        assertNotNull("Ensure constructor returns an object", instance);
    }
});
