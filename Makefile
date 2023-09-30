.PHONY: test test_extended

export TF_PATH

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(TF_PATH) ./aks_test.go

test_extended:
	cd tests && go test -v -timeout 60m -run TestAks ./aks_extended_test.go -tags extended
