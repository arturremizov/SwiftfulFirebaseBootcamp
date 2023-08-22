// https://firebase.google.com/docs/firestore/security/rules-structure

/*
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{user_id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == user_id;
      // allow write: if resource.data.is_premium == false
      // allow write: if request.resource.data.custom_key == "123"
      // allow write: if isPublic();
    }
    match /users/{user_id}/favorite_products/{id} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && request.auth.uid == user_id;
    }
    match /products/{product_id} {
      // allow read, write: if request.auth != null;
      // allow create: if request.auth != null;
      // allow read: if request.auth != null && isAdmin(request.auth.uid);
       allow read: if request.auth != null;
       allow create, update: if request.auth != null && isAdmin(request.auth.uid);
       allow delete: if false;
    }
  
    function isPublic() {
      return resource.data.visability == "public";
    }
    function isAdmin(user_id) {
       // let adminIds = ["smuVT5xW7ggBoD1SAaN0n20PKCU2", "abc"];
       // return user_id in adminIds;
       return exists(/databases/$(database)/documents/admins/$(user_id));
    }
  }
}

// read
// get - single document reads
// list - queries and collection read requests
//
// write
// create - add document
// update - update document
// delete - delete document
*/
