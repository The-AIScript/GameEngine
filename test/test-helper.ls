require! {
  should
}

exports.async-error-throw = (err, error-message, no-error-message = "No error founded!") ->
  should.exist err, no-error-message
  err.should.be.an.instanceof Error
  err.message.should.equal error-message
