#!/bin/bash

sendpoint=true

while getopts "u:" flag
do
    case "${flag}" in
        u) sendpoint=${OPTARG};;
    esac
done

echo "Sendpoint: $sendpoint";

id_turtlebot_docker='a4fb8eaeb7482e991e8c2e5ccca5bfd3dcb940d7f23007f8e72642f3f6c0ebef'
id_huggingface_docker='82ac9077583efeff7fa2e114fe203a9315d63674866fbea12da98a748cc5cb71'
a
while :
do
    echo -e "\nWrite the text request: "
    read text
    echo "Text: $text"

    if [ "$text" == "rotate" ]; then
        echo "How many degrees I should rotate (clockwise): "
        read degrees

        docker exec -it $id_turtlebot_docker /bin/bash -c "
                . /opt/ros/noetic/setup.bash && 
                . /home/rosuser/catkin_ws/devel/setup.bash && 
                export ROS_MASTER_URI=http://10.0.0.107:11311 &&
                rosrun beginner_tutorials navigation.py $degrees" 
    else

        docker exec -it $id_turtlebot_docker /bin/bash -c "
            . /opt/ros/noetic/setup.bash && 
            . /home/rosuser/catkin_ws/devel/setup.bash && 
            export ROS_MASTER_URI=http://10.0.0.107:11311 &&
            rosrun beginner_tutorials listener.py" 

        docker exec -it $id_huggingface_docker python /app/zero_shot.py $text
        theta=$?

        if [ $sendpoint == "true" ]; then
            echo "Sending Goal"
            docker exec -it $id_turtlebot_docker /bin/bash -c "
                . /opt/ros/noetic/setup.bash && 
                . /home/rosuser/catkin_ws/devel/setup.bash && 
                export ROS_MASTER_URI=http://10.0.0.107:11311 &&
                rosrun beginner_tutorials gotoapoint.py $theta" 
        fi
    fi    

    

done
