require! {
}

class AIEngine
  (@options = {}) ~>

  init: (callback) ~>
    @resource = @options.resource
    if not @resource
      callback new Error 'Must provide socket resource!'
    else
      callback null

exports = module.exports = AIEngine
