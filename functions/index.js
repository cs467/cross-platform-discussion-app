const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// All functions with "onCall" have not been scheduled and deployed. 

/************** FUNCTIONS TO STORE POST# COMMENTS **************/
// https://stackoverflow.com/questions/49691215/cloud-functions-how-to-copy-firestore-collection-to-a-new-document
exports.storePosts1 = functions.https.onCall((data, context) => {
  db.collection('posts1').get().then(snapshot => {
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(function (doc, i) {
      db.collection('storedPost1').add(doc.data());
    });
  }).catch(error => {
    console.log('Error message' + error);
  });
});

exports.storePosts2 = functions.https.onCall((data, context) => {
  db.collection('posts2').get().then(snapshot => {
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(function (doc, i) {
      db.collection('storedPost2').add(doc.data());
    });
  }).catch(error => {
    console.log('Error message' + error);
  });
});

exports.storePosts3 = functions.https.onCall((data, context) => {
  db.collection('posts3').get().then(snapshot => {
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(function (doc, i) {
      db.collection('storedPost3').add(doc.data());
    });
  }).catch(error => {
    console.log('Error message' + error);
  });
});

exports.storePosts4 = functions.https.onCall((data, context) => {
  db.collection('posts4').get().then(snapshot => {
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(function (doc, i) {
      db.collection('storedPost4').add(doc.data());
    });
  }).catch(error => {
    console.log('Error message' + error);
  });
});

exports.storePosts5 = functions.https.onCall((data, context) => {
  db.collection('posts5').get().then(snapshot => {
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(function (doc, i) {
      db.collection('storedPost5').add(doc.data());
    });
  }).catch(error => {
    console.log('Error message' + error);
  });
});

/***************************************************************************/

/******** FUNCTIONS TO DELETE (CLEAR FOR NEXT DAY) POST# COLLECTION ********/

exports.deletePosts1 = functions.https.onCall((data, context) => {
  deleteCollection('posts1', db);
});
exports.deletePosts2 = functions.https.onCall((data, context) => {
  deleteCollection('posts2', db);
});
exports.deletePosts3 = functions.https.onCall((data, context) => {
  deleteCollection('posts3', db);
});
exports.deletePosts4 = functions.https.onCall((data, context) => {
  deleteCollection('posts4', db);
});
exports.deletePosts5 = functions.https.onCall((data, context) => {
  deleteCollection('posts5', db);
});

/***************************************************************************/

// This function has been deployed. 
// This funtion gets the top 5 prompt proposals and replace the current ones. 
exports.getFiveProposals = functions.pubsub.topic('replaceFivePrompts').onPublish((data, context) => {
  var list = [];
  db.collection('proposal').orderBy('likes', 'desc').limit(5).get().then(snapshot => {
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }

    snapshot.forEach(doc => {
      list.push(doc.data().body);
    });

    db.collection('prompts').get().then(snapshot => {
      if (snapshot.empty) {
        console.log('No matching documents.');
        return;
      }

      // If list[i] is null, set the prompt equal to the original one. 
      // Perhaps in the future we can have a preloaded set of prompts to
      // pull from when we run into a situation where five prompt proposals
      // are not available.
      snapshot.docs.forEach(function (value, i) {
        value.ref.update({
          prompt: list[i] ? list[i] : value.data().prompt
        });
      })
      return;
    }).catch(error => {
      console.log('Error message' + error);
    })
    return;
  }).catch(error => {
    console.log('Error message' + error);
  });
});

// This function has been deployed. 
// It deletes all current prompt proposals. 
exports.deleteProposals = functions.pubsub.topic('deleteProposals').onPublish((data, context) => {
  deleteCollection('proposal', db);
});

// Pass the database and collection to be deleted. 
async function deleteCollection(collection, db) {
  const collectionRef = db.collection(collection);
  const query = collectionRef

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();

  // When there are no documents left, we are done
 if (snapshot.size === 0) {
  resolve();
  return;
 }

  // Delete documents in a batch
  snapshot.docs.forEach((doc) => {
    doc.ref.delete();
  });

  // Recurse on the next process tick, to avoid
  // exploding the stack.
  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}
