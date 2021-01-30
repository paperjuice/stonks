module Main exposing (main)

import Browser
import Html exposing (Html, text, pre, div, input, span, button, br)
import Http exposing (stringBody)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value, placeholder, type_)
import Dict exposing (Dict)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder, int, float, list, string)
import Json.Decode.Pipeline exposing (required)
import Round


-- TODO: validate that percentage allocation does not go past 100%

--TODO: use env variables
beUrl = "http://localhost"
bePort = "9980"
worthEndpoint = "worth"

-- MAIN
main =
  Browser.element
    { init = init
    , update = update
    , subscriptions =  (\_ -> Sub.none)
    , view = view
    }

-- MODEL
type Msg
  = Home
  | StartDate String
  | InitialBalance String
  | UpdateSymbol Int String
  | AddPortfolio
  | UpdateAllocation Int String
  | SendRequest
  | HandleResponse (Result Http.Error String)
  | OkError

type State
  = Success
  | Loading
  | Error

type alias Model =
  { request : Request
  , state : State
  , portfolioCount : Int
  , response: Response
  }

type alias Request =
  { startDate : String
  , initialBalance : String
  , portfolioAllocation : Dict Int Portfolio
  }

type alias Portfolio =
  { symbol : String
  , allocation: String
  }

init : () -> (Model, Cmd Msg)
init _ =
   ( Model (Request "" "" (Dict.singleton 1 (Portfolio "" ""))) Success 1 (Response 0 [])
   ,Cmd.none
   )

-- ENCODER --
requestEncoder : Request -> Encode.Value
requestEncoder requestData =
  case String.toInt requestData.initialBalance of
    Just balance ->
      Encode.object
        [ ( "start_date", Encode.string requestData.startDate)
        , ( "initial_balance", Encode.int balance)
        , ("portfolio_allocation", Encode.list portfolioAllocationEncoder (Dict.toList requestData.portfolioAllocation))
        ]

    Nothing ->
      Encode.object
        [ ( "start_date", Encode.string requestData.startDate)
        , ( "initial_balance", Encode.int 0)
        , ("portfolio_allocation", Encode.list portfolioAllocationEncoder (Dict.toList requestData.portfolioAllocation))
        ]

portfolioAllocationEncoder : (Int, Portfolio) -> Encode.Value
portfolioAllocationEncoder (_, portfolioAllocation) =
    case String.toInt portfolioAllocation.allocation of
      Just allocation ->
        Encode.object
          [ ("symbol", Encode.string portfolioAllocation.symbol)
          , ("allocation", Encode.int allocation)
          ]
      Nothing ->
        Encode.object
          [ ("symbol", Encode.string portfolioAllocation.symbol)
          , ("allocation", Encode.int 0)
          ]

-- DECODER --
type alias Response =
  { total : Float
  , data : List DataResponse
  }

type alias DataResponse =
  { symbol: String
  , stockNum: Float
  , reservedBalance: Float
  , pastDate: String
  , pastClose: Float
  , currentStockWorth: Float
  , currentDate: String
  , currentClose: Float
  }


responseDecoder : Decoder Response
responseDecoder =
  Decode.succeed Response
  |> required "total" float
  |> required "data" (list dataDecoder)

dataDecoder : Decoder DataResponse
dataDecoder =
  Decode.succeed DataResponse
  |> required "symbol" string
  |> required "stock_num" float
  |> required "reserved_balance" float
  |> required "past_date" string
  |> required "past_close" float
  |> required "current_stock_worth" float
  |> required "current_date" string
  |> required "current_close" float

sendRequest : Request -> Cmd Msg
sendRequest requestData =
  let
    jsonPayload = stringBody "application/json" (Encode.encode 0 (requestEncoder requestData))

  in
   Http.request
      { method = "POST"
      , headers = [ ]
      , url = Debug.log "URL" (String.concat [beUrl, ":", bePort, "/", worthEndpoint])
      , body = jsonPayload
      , expect = Http.expectString HandleResponse
      , timeout = Nothing
      , tracker = Nothing
      }

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
      req = model.request
  in
      case msg of
        Home ->
          (model, Cmd.none)

        OkError ->
          ({model | state = Success}, Cmd.none )

        SendRequest ->
          ({model | state = Loading}, sendRequest model.request)

        HandleResponse result ->
          case (Debug.log "resp" result) of
            Ok json ->
              let
                  decode = Decode.decodeString responseDecoder json

                  newResponse =
                    case (Debug.log "hello" decode) of
                      Ok response -> response

                      Err _ -> Response 0 []
              in
              ({model | response = newResponse, state = Success}, Cmd.none)

            Err _ ->
              (model, Cmd.none)

        StartDate newStartDate ->
          let
              newRequest = {req | startDate = (Debug.log "date" newStartDate)}
          in
              ({model | request = newRequest}, Cmd.none)

        InitialBalance newBalance ->
          let
              newRequest = {req | initialBalance = (Debug.log "balance" newBalance)}
          in
              ({model | request = newRequest}, Cmd.none)

        AddPortfolio ->
          let
              newPortfolioCount = model.portfolioCount + 1
              portfolioAllocation = model.request.portfolioAllocation
              newPortfolioAllocation = Dict.insert newPortfolioCount (Portfolio "" "") portfolioAllocation
              request = model.request
              newRequest = { request | portfolioAllocation = newPortfolioAllocation }
          in
              ({model | request = newRequest, portfolioCount = newPortfolioCount}, Cmd.none)


        UpdateSymbol key newSymbol ->
          let
              newPortfolio =
                Dict.update key (Maybe.map (\value -> {value | symbol = newSymbol})) model.request.portfolioAllocation

              request = model.request
              newRequest = {request | portfolioAllocation = newPortfolio}

          in
              ( {model | request = newRequest} , Cmd.none )

        UpdateAllocation key newAllocation ->
          let
              newPortfolio =
                Dict.update key (Maybe.map (\value -> {value | allocation = newAllocation})) model.request.portfolioAllocation

              request = model.request
              newRequest = {request | portfolioAllocation = newPortfolio}
          in
              ( {model | request = newRequest} , Cmd.none )


-- VIEW
view : Model -> Html Msg
view model = homePage model

homePage : Model -> Html Msg
homePage model =
  div [ ]
      [ div [ ]
            [ text "STONKS"
            ]
      , br [] []
      , br [] []
      , div [ ]
            [ span [ ] [ text "Start Date: " ]
            , input [ type_ "date", placeholder "2013-07-01", value model.request.startDate, onInput StartDate] []
            ]
      , div [ ]
            [ span [ ] [ text "Initial Balance: " ]
            , input [ type_ "number", placeholder "3200", value model.request.initialBalance, onInput InitialBalance] []
            , span [ ] [ text "$" ]
            ]
      , div [ ]
            [ div [ ]
                  [ text "Portfolio Allocation (please make sure the total allocation is 100%): " ]
            , div [ ] (buildPortfolioAllocation (Dict.toList model.request.portfolioAllocation) [])
            ]
      , br [] []
      , div [ ]
            [ button [ onClick AddPortfolio ] [ text "Insert new market symbol & allocation" ]
            ]
      , div [ ] [ text "--------------------------------" ]
      , br [] []
      , br [] []
      , div [ ]
            [ button [ onClick SendRequest ] [ text "SEND REQUEST" ]
            ]
      , buildLoadingMessage model.state
      , br [][]
      , br [][]
      , div [ ] [ text "-------- RESPONSE ---------" ]
      , buildResponseView model.response
      ]

buildErrorMessage state error =
  if state == Error then
    div [ ]
        [ span [ ] [ text error ]
        , button [ onClick OkError ] [ text "Okey dokey" ]
        ]
  else
    div [ ] []

buildLoadingMessage state =
  if state == Loading then
    div [ ]
        [ text "Please bear with me while we are processing your request, thank you <3"
        ]
  else
    div [ ] []
buildResponseView : Response -> Html msg
buildResponseView response =
  if response.total /= 0 then
    div [ ]
        [ div [ ]
              [  span [ ] [ text (String.concat ["Total hypotetical worth of the stocks today is: ", (Round.round 2 response.total), "$"])]
              ]
        , div [ ] (buildResponseDataView response.data)
        ]
  else
    div [ ] [ ]

buildResponseDataView : List DataResponse -> List (Html msg)
buildResponseDataView dataList =
  List.map (\d ->
    div [ ]
        [  div [ ]
               [ text " --------------------------------- "
              ]
        ,  div [ ]
              [ span [ ] [ text "Symbol: " ]
              , span [ ] [ text d.symbol ]
              ]
        , div [ ]
              [ span [ ] [ text (String.concat ["Finance reserved for this stocks: ", (Round.round 2 d.reservedBalance), "$"]) ]
              ]
        , div [ ]
              [ span [ ] [ text (String.concat ["On  ", d.pastDate, " one stock was worth ", (Round.round 2 d.pastClose), "$"]) ]
              ]
        , div [ ]
              [ span [ ] [ text (String.concat ["Amount of stocks you could buy on  ", d.pastDate, ": ", (Round.round 2 d.stockNum)]) ]
              ]
        , div [ ]
              [ span [ ] [ text (String.concat ["Today (", d.currentDate, ") one stock is worth ", (Round.round 2 d.currentClose), "$"]) ]
              ]
        , div [ ]
              [ span [ ] [ text (String.concat ["Total gain today (", d.currentDate, "), for ", d.symbol,  " is ", (Round.round 2 d.currentStockWorth), "$"]) ]
              ]
        ]
    ) dataList

buildPortfolioAllocation : List (Int, Portfolio) -> List (Html Msg) -> List (Html Msg)
buildPortfolioAllocation portfolioAllocation inputDiv =
  case portfolioAllocation of
    ((k, v) :: tl) ->
      let
          marketInput =
            div [ ]
                [ span [ ] [ text "Symbol: " ]
                , input [ type_ "text", placeholder "AAPL", value v.symbol, onInput (UpdateSymbol k)] [ ]
                , span [ ] [ text "Allocation: " ]
                , input [ type_ "number", placeholder "20", value v.allocation, onInput (UpdateAllocation k)] [ ]
                , span [ ] [ text "%" ]
                ]
      in
          buildPortfolioAllocation tl (marketInput :: inputDiv)

    [] -> inputDiv

