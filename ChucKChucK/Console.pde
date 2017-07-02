class Console{
  StringList tlist;

  Console(){
    tlist = new StringList();
  }

  String get(){
    String text="";
    for(int i=0;i<tlist.size()-1;i++){
      try{
        text+=tlist.get(i)+"\n";
      }catch(Exception e){
        println("shift !");
      }
    }
    return text;
  }
  void set(String v){
    tlist.insert(0,v);
    if(tlist.size()>20)tlist.pop();
  }
}