<?php
// echo $_GET['mail'];
// echo $_GET['password'];


$link = mysqli_connect('127.0.0.1:3306', 'root', '', 'gisit23');
if (!$link) {
    die('Ошибка соединения: ' . mysqli_error());
}

$text = file_get_contents("php://input");
$in = json_decode($text, true);

// echo $text;
// echo $in['name'];
// echo $in['email'];

$result = $link->query("SELECT * FROM users WHERE email= '".$in['email']."'");
$row = $result->fetch_assoc();



if (is_null($row['password']) === TRUE){
    echo "Error: not registered";

} else {
    if ($row['password']==$in['password']) {
        echo json_encode($row);
    } else {
        echo "Error: incorrect password";
    }
}
?>



