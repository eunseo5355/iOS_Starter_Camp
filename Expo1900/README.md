# Exposition Universelle🇰🇷
만국박람회 프로젝트 저장소

[STEP 1](#step-1) <br>
[STEP 2](#step-2)

### 📱실행화면
![Expo 실행화면](https://user-images.githubusercontent.com/55755686/115770650-eafaa600-a3e7-11eb-906a-89752c4dcaed.gif)

---

## STEP 1 
### JSON 데이터와 매칭할 모델 타입 구현✨
- ```Expo```
    - CodingKeys 구현
    <br> CodingKey를 채택하여 스네이크 케이스인 JSON 타입의 Key를 소문자 카멜케이스로 바꿔줌
- ```EntryWorkItem```

👉 두 타입 모두 Decodable 채택
<br>JSON 타입으로 변환시킬 수 있는 인코딩 기능은 필요없다고 생각함

### 📚학습 내용
|KeyWord|Description|
|---|---|
|JSON|데이터를 저장하거나 전송할 때 많이 사용되는 경량의 DATA 교환 형식|
|Decoding|인코딩된 정보를 부호화되기 전으로 되돌리는 처리 혹은 처리 방식|
|Encoding|다른 형태나 형식으로 변환하는 처리 혹은 처리 방식 ex) Swift → JSON|
|Codable|Decodable과 Encodable 프로토콜을 결합한 typealias|
|CodingKey|인코딩 및 디코딩을 위한 키로 사용할 수 있는 프로토콜|

---

## STEP 2
### 화면 구현✨
- ```ExpoViewController```
    - JSON 데이터 디코딩하여 UI가 업데이트 되도록 구현
    - JSON 디코딩하는 메소드(```loadJsonData()```)의 반환타입을 Result 타입으로 지정
    - 숫자 세자리 수마다 콤마(,) 찍어주는 메소드 구현 (```NumberFormatter()``` 사용)
    - 버튼을 누르면 화면 전환되는 메소드 구현
- ```EntryWorkViewController```
    - JSON 데이터 디코딩하여 UI가 업데이트 되도록 구현
    - JSON 디코딩하는 메소드(```loadJsonData()```)의 반환타입을 Result 타입으로 지정
    - Table View 구현
    - cell 클릭시 선택한 셀의 데이터를 화면 전환하면서 넘겨줌
        <br> 
        ```Swift
        guard let entryWorkDetailViewController = self.storyboard?.instantiateViewController(identifier: "entryWorkDetailVC") as? EntryWorkDetailViewController else { return }
        entryWorkDetailViewController.entryWorkItem = entryWorks[indexPath.row]
        self.navigationController?.pushViewController(entryWorkDetailViewController, animated: true)
        ```
        - 전환할 화면의 storyboard identifier를 설정해준 후 instantiateViewController를 사용하여 해당 identifier의 ViewController 선언
        - 전환할 화면의 프로퍼티에 접근하여 해당 셀의 데이터 대입
        <br> 주의❗️ 해당 뷰 컨트롤러의 프로퍼티에 데이터를 넣어줬다해도 push나 present를 하지 않으면 데이터가 전달되지 않음
        -  마지막으로 navigation의 push를 통해 화면전환하면서 데이터도 같이 넘겨줌

- ```EntryWorkDetailViewController```
    - entryWorkItem 프로퍼티로 데이터를 전달받아서 UI를 업데이트 시켜줌

### loadJsonData() 메소드
- 개선한 점
    - 초기 구현
    <br> 파일명이 잘못되었거나 디코딩 실패했을때 nil을 반환시켜주거나 메소드를 종료되도록 구현
    - 문제점
    <br> 어떤 오류인지 정확히 알 수 없음
    - 개선
    <br> Result 타입을 반환시키도록 구현하여 성공했을 때는 디코딩한 데이터를 Success 값에 담아서 반환해주고 실패했을 때는 그에 따른 오류를 Failure 값에 담아서 반환하도록 구현
- Asset에 넣어준 데이터 가져오기 <br>
```guard let dataAsset = NSDataAsset.init(name: "items") else { return .failure(.incorrectAssert) }```
```NSDataAsset.init(name:)``` 을 사용하여 name에 작성한 파일의 데이터를 guard 구문을 사용하여 안전하게 가져와줌

### 📚학습 내용
- **Table View**(UITableView)
    - 테이블 뷰는 간단한 형태의 리스트로, 각 항목은 Cell이라고 부른다.
    - **Plain, Grouped, Inset Grouped** 세 가지 스타일이 있다.
    - 하나 이상의 섹션을 가질 수 있으며, 각 섹션은 여러 개의 행을 지닐 수 있다.
    - 테이블 뷰는 **동적 프로토타입(Dynamic Prototypes)** 과 **정적 셀(Static Cells)** 두 가지 특성 중 선택하여 생성할 수 있다.
        - 동적 프로토타입(Dynamic Prototypes)
        <br> DataSource의 인스턴스로 콘텐츠를 관리하며, 상황에 따라 셀의 갯수가 변해야할때 사용한다.(default 값)
        - 정적 셀(Static Cells)
        <br> 고유의 레이아웃과 고정된 수의 행을 가지는 테이블 뷰로 셀의 갯수가 정해져있는 경우에 사용한다.
    - **DataSource**(UITableViewDataSource)
        - 데이터를 관리하고 테이블 뷰에 셀을 제공
        - 테이블 뷰는 데이터 자체를 관리하지 않기 때문에 데이터를 관리하려면 UITableViewDataSource 프로토콜을 구현해야 한다.
    - **Delegate**(UITableViewDelegate)
        - 테이블 뷰의 시각적인 부분(모양) 수정, 어떤 행동에 대한 동작을 제시 ex) row를 클릭(행동)하면 얼럿을 띄운다(동작)
    



