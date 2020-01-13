var component;
var sprite;
var coids = [];


//this function is the universal component create function. This is used to create a new
//lesson (without a coid) and is used for creating a new component (with a coid).
function createBucket(parent,cotype,properties,coid) {
    console.log("bucketCreate.js:creation started")
    component = Qt.createComponent(cotype);
    console.log("bucketCreate.js:",cotype)
    if (component.status === Component.Ready)
        finishCreation(parent,properties,coid);
    else
        console.log("bucketCreate.js:",component.errorString())
        component.statusChanged.connect(finishCreation);
}

//this function is used to finish the component creation
function finishCreation(parent,properties,coid) {
    if (component.status === Component.Ready) {

        sprite = component.createObject(parent, properties); //This is where you can set the id to be a dynamic id
        if (sprite === null) {
                    // Error Handling
                    console.log("Error creating object");
                }
            } else if (component.status === Component.Error) {
                // Error Handling
                console.log("Error loading component:", component.errorString());
            }
    }
