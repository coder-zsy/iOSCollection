/**
 * webViewDidStartLoad 加载才有效*/
window.onload = function () {
	console.log('页面加载完毕');
	testFunction();
	shareWebWithURL('===');
}

function testFunction () {
	console.log('方法测试2222');
}

//function testFunction3 () {
//    console.log('方法测试33333333');
//}
//
//(function () {
// /**
//  * webViewDidFinishLoad 再加载才有效*/
// console.log('自执行方法');
//})();


