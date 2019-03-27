const formatChannelName = name => {
  return name.toLowerCase().split(" ").join("-");
}

export default formatChannelName;
