const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

exports.getFiveProposals = functions.https.onCall((data, context) => {
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

    snapshot.docs.forEach(function (value, i) {
      value.ref.update({
        prompt: list[i]
      });
    })
  })
  });
});

exports.deleteProposals = functions.https.onCall((data, context) => {
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
