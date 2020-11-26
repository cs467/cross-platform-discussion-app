const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

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
    if(snapshot.empty) {
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

exports.deleteProposals = functions.pubsub.topic('deleteProposals').onPublish((data, context) => {
  deleteCollection(db);
});

async function deleteCollection(db) {
  const collectionRef = db.collection('proposal');
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
